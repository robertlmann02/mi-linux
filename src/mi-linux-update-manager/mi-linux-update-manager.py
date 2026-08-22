#!/usr/bin/env python3
"""GTK/GNOME MI Linux Update Manager for Founder Preview."""
import os
import shlex
import subprocess
from datetime import datetime

import gi
gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, GLib

APP_ID = 'org.mannindustries.MILinuxUpdateManager'


def have(cmd):
    return subprocess.call(['sh', '-lc', f'command -v {shlex.quote(cmd)} >/dev/null 2>&1']) == 0


class UpdateManager(Gtk.Application):
    def __init__(self):
        super().__init__(application_id=APP_ID)
        self.proc = None
        self.buttons = []
        self.current_label = ''
        self.current_output = []

    def do_activate(self):
        win = Gtk.ApplicationWindow(application=self)
        win.set_title('MI Linux Update Manager')
        win.set_default_size(860, 620)

        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        outer.set_margin_top(18)
        outer.set_margin_bottom(18)
        outer.set_margin_start(18)
        outer.set_margin_end(18)

        title = Gtk.Label(label='MI Linux Forky Founder Updates')
        title.add_css_class('title-1')
        title.set_xalign(0)
        outer.append(title)

        subtitle = Gtk.Label(
            label=(
                'Channel: forky-founder\n'
                'Security updates: automatic through unattended-upgrades\n'
                'System updates: run here when you are ready. A Timeshift snapshot is recommended first.'
            )
        )
        subtitle.set_xalign(0)
        outer.append(subtitle)

        grid = Gtk.Grid(column_spacing=10, row_spacing=10)
        actions = [
            ('Check for Updates', self.check_updates),
            ('Create Timeshift Snapshot', self.create_snapshot),
            ('Install Available Updates', self.install_updates),
            ('Show Security / Timer Status', self.security_status),
            ('Open GNOME Software Updates', self.open_gnome_software),
        ]
        for idx, (text, callback) in enumerate(actions):
            btn = Gtk.Button(label=text)
            btn.connect('clicked', callback)
            btn.set_hexpand(True)
            grid.attach(btn, idx % 2, idx // 2, 1, 1)
            self.buttons.append(btn)
        outer.append(grid)

        self.status = Gtk.Label(label='Ready.')
        self.status.set_xalign(0)
        outer.append(self.status)

        self.output = Gtk.TextView()
        self.output.set_editable(False)
        self.output.set_monospace(True)
        self.output.set_wrap_mode(Gtk.WrapMode.WORD_CHAR)
        self.buffer = self.output.get_buffer()

        scroller = Gtk.ScrolledWindow()
        scroller.set_hexpand(True)
        scroller.set_vexpand(True)
        scroller.set_child(self.output)
        outer.append(scroller)

        win.set_child(outer)
        win.present()
        self.run_cmd('Initial status', 'apt list --upgradable 2>/dev/null | sed -n "1,80p"', needs_root=False)

    def set_busy(self, busy):
        for button in self.buttons:
            button.set_sensitive(not busy)

    def append(self, text):
        end = self.buffer.get_end_iter()
        self.buffer.insert(end, text)
        mark = self.buffer.create_mark(None, self.buffer.get_end_iter(), False)
        self.output.scroll_to_mark(mark, 0.0, True, 0.0, 1.0)

    def command_prefix(self, needs_root):
        if not needs_root:
            return ''
        if subprocess.call(['sudo', '-n', 'true'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0:
            return 'sudo -n '
        return 'pkexec env DEBIAN_FRONTEND=noninteractive '

    def run_cmd(self, label, cmd, needs_root=False):
        if self.proc is not None:
            return
        prefix = self.command_prefix(needs_root)
        if needs_root and prefix.startswith('sudo'):
            full_cmd = 'sudo -n env DEBIAN_FRONTEND=noninteractive sh -lc ' + shlex.quote(cmd)
        elif needs_root and prefix.startswith('pkexec'):
            full_cmd = 'pkexec env DEBIAN_FRONTEND=noninteractive sh -lc ' + shlex.quote(cmd)
        else:
            full_cmd = cmd
        stamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        self.buffer.set_text(f'$ {label}\n[{stamp}] {full_cmd}\n\n')
        self.current_label = label
        self.current_output = []
        self.status.set_text(f'Running: {label}')
        self.set_busy(True)
        env = os.environ.copy()
        env.setdefault('DEBIAN_FRONTEND', 'noninteractive')
        self.proc = subprocess.Popen(
            ['/bin/sh', '-lc', full_cmd],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            stdin=subprocess.DEVNULL,
            text=True,
            bufsize=1,
            env=env,
        )
        GLib.io_add_watch(self.proc.stdout, GLib.IO_IN | GLib.IO_HUP | GLib.IO_ERR, self.on_output)
        GLib.timeout_add(500, self.on_poll)

    def on_output(self, stream, condition):
        if condition & (GLib.IO_HUP | GLib.IO_ERR):
            return False
        line = stream.readline()
        if line:
            self.current_output.append(line)
            self.append(line)
            return True
        return False

    def on_poll(self):
        if self.proc is None:
            return False
        rc = self.proc.poll()
        if rc is None:
            return True
        try:
            stdout = self.proc.stdout
            remaining = stdout.read() if stdout is not None else ''
            if remaining:
                self.current_output.append(remaining)
                self.append(remaining)
        except Exception:
            pass
        message = self.friendly_result(rc, ''.join(self.current_output))
        self.append(f'\n{message}\n')
        self.status.set_text(message)
        self.proc = None
        self.set_busy(False)
        return False

    def friendly_result(self, rc, output):
        """Return a plain-English result instead of exposing shell exit codes."""
        text = output.lower()
        if rc != 0:
            if self.current_label == 'Create Timeshift Snapshot':
                return 'The snapshot did not complete. Please try again or check Timeshift.'
            if self.current_label == 'Install Available Updates':
                if 'permission denied' in text or 'are you root' in text or 'could not open lock file' in text:
                    return 'The update tool did not get administrator permission. Please try again after signing in as an administrator.'
                if 'could not get lock' in text or 'unable to acquire the dpkg frontend lock' in text:
                    return 'Another update tool is already running. Close other software/update windows and try again.'
                return 'The updates did not install. Please review the details above.'
            if self.current_label == 'Check for Updates':
                return 'The update check did not finish. Please review the details above.'
            return 'That task did not complete. Please review the details above.'

        if self.current_label in ('Initial status', 'Check for Updates'):
            if 'upgradable from:' in text:
                return 'Updates are available. You can install them when you are ready.'
            return 'Your system is up to date. No updates were found.'
        if self.current_label == 'Install Available Updates':
            if '0 upgraded, 0 newly installed, 0 to remove' in text:
                if 'kept back' in text or 'not upgraded' in text:
                    return 'Regular updates are installed. Some larger system updates are being held back for a safer upgrade path.'
                return 'Your system was already up to date. Nothing needed to be installed.'
            if 'upgraded,' in text or 'setting up ' in text or 'installing new version' in text:
                return 'Updates were installed successfully.'
            return 'The update install finished successfully.'
        if self.current_label == 'Create Timeshift Snapshot':
            return 'The Timeshift safety snapshot was created successfully.'
        if self.current_label == 'Security / Timer Status':
            return 'Security and update timer status loaded successfully.'
        return 'Done successfully.'

    def check_updates(self, *_):
        self.run_cmd(
            'Check for Updates',
            'apt-get update && apt list --upgradable 2>/dev/null | sed -n "1,160p"',
            needs_root=True,
        )

    def create_snapshot(self, *_):
        if not have('timeshift'):
            self.buffer.set_text('Timeshift is not installed. Install the timeshift package first.\n')
            return
        self.run_cmd(
            'Create Timeshift Snapshot',
            'timeshift --create --comments "MI Linux pre-update snapshot" --tags D',
            needs_root=True,
        )

    def install_updates(self, *_):
        self.run_cmd(
            'Install Available Updates',
            'systemctl stop packagekit 2>/dev/null || true; '
            'apt-get -o DPkg::Lock::Timeout=180 update && '
            'DEBIAN_FRONTEND=noninteractive apt-get '
            '-o DPkg::Lock::Timeout=180 '
            '-o Dpkg::Options::=--force-confdef '
            '-o Dpkg::Options::=--force-confold '
            '-y upgrade',
            needs_root=True,
        )

    def security_status(self, *_):
        self.run_cmd(
            'Security / Timer Status',
            'printf "Firewall: "; systemctl is-active ufw || true; '
            'sudo -n ufw status verbose 2>/dev/null || ufw status verbose 2>/dev/null || true; '
            'printf "\\nUpdate timers:\\n"; systemctl list-timers "apt-*" "mi-linux-*" --no-pager; '
            'printf "\\nUnattended upgrades:\\n"; systemctl status unattended-upgrades --no-pager | sed -n "1,60p"',
            needs_root=False,
        )

    def open_gnome_software(self, *_):
        subprocess.Popen(['gnome-software', '--mode=updates'], stdin=subprocess.DEVNULL)
        self.status.set_text('Opened GNOME Software updates.')


if __name__ == '__main__':
    app = UpdateManager()
    app.run(None)
