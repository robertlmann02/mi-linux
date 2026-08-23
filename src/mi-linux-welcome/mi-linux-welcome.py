#!/usr/bin/env python3
"""GTK/GNOME MI Linux Welcome app for Founder Preview."""
import os
from pathlib import Path
import shutil
import subprocess

import gi

gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, GLib

APT_APPS = {
    'Gaming': [
        ('Steam', ['steam-installer', 'steam-devices']),
        ('Lutris', ['lutris']),
        ('GameMode + MangoHud', ['gamemode', 'mangohud']),
        ('OBS Studio', ['obs-studio']),
    ],
    'Windows Apps': [
        ('Bottles', ['bottles']),
        ('Wine + Winetricks', ['wine', 'winetricks']),
        ('PlayOnLinux', ['playonlinux']),
    ],
    'Creative Tools': [
        ('GIMP', ['gimp']),
        ('Inkscape', ['inkscape']),
        ('Krita', ['krita']),
        ('Blender', ['blender']),
        ('Kdenlive', ['kdenlive']),
        ('Audacity', ['audacity']),
    ],
    'Developer Tools': [
        ('Git', ['git']),
        ('Podman', ['podman']),
        ('Docker tools', ['docker.io', 'docker-compose-plugin']),
        ('Python tooling', ['python3-venv', 'python3-pipx', 'pipx']),
        ('Node.js tooling', ['nodejs', 'npm']),
    ],
    'Android Apps / Waydroid': [
        ('Waydroid', ['waydroid']),
    ],
}

WEB_APPS = {
    'Browsers': [
        ('Google Chrome download page', 'https://www.google.com/chrome/'),
        ('Microsoft Edge download page', 'https://www.microsoft.com/edge/download'),
    ],
    'Gaming': [
        ('Heroic Games Launcher download page', 'https://heroicgameslauncher.com/downloads'),
        ('ProtonUp-Qt download page', 'https://davidotek.github.io/protonup-qt/'),
        ('Discord download page', 'https://discord.com/download'),
    ],
    'Developer Tools': [
        ('VS Code download page', 'https://code.visualstudio.com/download'),
        ('VSCodium download page', 'https://vscodium.com/'),
        ('GitHub Desktop download page', 'https://github.com/shiftkey/desktop/releases'),
    ],
}

NVIDIA_PACKAGES = ['nvidia-driver', 'nvidia-settings', 'firmware-misc-nonfree']


def has_nvidia_gpu():
    if not shutil.which('lspci'):
        return False
    try:
        out = subprocess.check_output(['lspci', '-nn'], text=True, stderr=subprocess.DEVNULL)
    except Exception:
        return False
    return 'NVIDIA' in out or '10de:' in out.lower()


def autostart_override_path():
    config_home = Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config'))
    return config_home / 'autostart' / 'mi-linux-welcome.desktop'


def welcome_autostart_enabled():
    override = autostart_override_path()
    if not override.exists():
        return True
    try:
        return 'Hidden=true' not in override.read_text()
    except Exception:
        return True


def set_welcome_autostart(enabled):
    override = autostart_override_path()
    override.parent.mkdir(parents=True, exist_ok=True)
    if enabled:
        if override.exists():
            override.unlink()
        return
    override.write_text('[Desktop Entry]\nType=Application\nName=Welcome to MI Linux\nExec=mi-linux-welcome\nHidden=true\n')


def command_exists(name):
    return shutil.which(name) is not None


class Welcome(Gtk.Application):
    def __init__(self):
        super().__init__(application_id='org.mannindustries.MILinuxWelcome')
        self.status = None
        self.win = None

    def do_activate(self):
        self.win = Gtk.ApplicationWindow(application=self)
        self.win.set_title('Welcome to MI Linux')
        self.win.set_default_size(940, 720)

        scroll = Gtk.ScrolledWindow()
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        box.set_margin_top(18)
        box.set_margin_bottom(18)
        box.set_margin_start(18)
        box.set_margin_end(18)

        title = Gtk.Label(label='Welcome to MI Linux Forky Founder')
        title.add_css_class('title-1')
        title.set_xalign(0)
        box.append(title)

        self.status = Gtk.Label(label='Security protection is active\nFirewall: On\nSecurity updates: On\nMalware scan schedule: On\nRootkit scan schedule: On')
        self.status.set_xalign(0)
        self.status.set_wrap(True)
        box.append(self.status)

        startup_box = Gtk.CheckButton(label='Show Welcome at startup')
        startup_box.set_active(welcome_autostart_enabled())
        startup_box.set_tooltip_text('Leave this checked while setting up MI Linux. Uncheck it when you do not want Welcome to open after login.')
        startup_box.connect('toggled', self.on_startup_toggled)
        box.append(startup_box)

        quick = Gtk.Label(label='Quick Actions')
        quick.add_css_class('title-2')
        quick.set_xalign(0)
        box.append(quick)
        quick_grid = Gtk.FlowBox()
        quick_grid.set_selection_mode(Gtk.SelectionMode.NONE)
        for label, cmd in [
            ('Open Update Manager', ['mi-linux-update-manager']),
            ('System Restore / Timeshift', ['timeshift-launcher']),
            ('Open GNOME Software', ['gnome-software']),
            ('Visit MI Linux Website', ['xdg-open', 'https://mannindustries.org/mi-linux']),
        ]:
            b = Gtk.Button(label=label)
            b.connect('clicked', lambda _b, c=cmd: self.run_plain(c))
            quick_grid.append(b)
        box.append(quick_grid)

        hw = Gtk.Label(label='Drivers / Hardware')
        hw.add_css_class('title-2')
        hw.set_xalign(0)
        box.append(hw)
        detected = has_nvidia_gpu()
        msg = 'NVIDIA GPU detected.' if detected else 'No NVIDIA GPU was detected in this session. The button is still available if you install onto NVIDIA hardware later.'
        hw_msg = Gtk.Label(label=msg)
        hw_msg.set_xalign(0)
        hw_msg.set_wrap(True)
        box.append(hw_msg)
        nvidia = Gtk.Button(label='Install NVIDIA Driver')
        nvidia.connect('clicked', lambda _b: self.install_apt('NVIDIA Driver', NVIDIA_PACKAGES, reboot=True))
        box.append(nvidia)

        rec = Gtk.Label(label='Recommended Apps')
        rec.add_css_class('title-2')
        rec.set_xalign(0)
        box.append(rec)
        note = Gtk.Label(label='Click an app to install it. Apps installed from the live USB are temporary; install MI Linux first if you want them to remain after reboot.')
        note.set_xalign(0)
        note.set_wrap(True)
        box.append(note)

        for cat, apps in APT_APPS.items():
            box.append(self.category_label(cat))
            flow = Gtk.FlowBox()
            flow.set_selection_mode(Gtk.SelectionMode.NONE)
            flow.set_max_children_per_line(4)
            for label, packages in apps:
                b = Gtk.Button(label=label)
                b.connect('clicked', lambda _b, l=label, p=packages: self.install_apt(l, p))
                flow.append(b)
            box.append(flow)

        for cat, apps in WEB_APPS.items():
            box.append(self.category_label(f'{cat} downloads'))
            flow = Gtk.FlowBox()
            flow.set_selection_mode(Gtk.SelectionMode.NONE)
            flow.set_max_children_per_line(3)
            for label, url in apps:
                b = Gtk.Button(label=label)
                b.connect('clicked', lambda _b, u=url: self.run_plain(['xdg-open', u]))
                flow.append(b)
            box.append(flow)

        scroll.set_child(box)
        self.win.set_child(scroll)
        self.win.present()

        if detected:
            GLib.idle_add(self.show_nvidia_notice)

    def category_label(self, label):
        l = Gtk.Label(label=label)
        l.add_css_class('heading')
        l.set_xalign(0)
        return l

    def set_status(self, text):
        if self.status:
            self.status.set_text(text)

    def on_startup_toggled(self, button):
        enabled = button.get_active()
        set_welcome_autostart(enabled)
        if enabled:
            self.set_status('Welcome will open automatically after login.')
        else:
            self.set_status('Welcome will no longer open automatically after login. You can still open it from the menu or favorites.')

    def run_plain(self, cmd):
        try:
            subprocess.Popen(cmd)
            self.set_status('Opened: ' + ' '.join(cmd))
        except Exception as exc:
            self.set_status(f'Could not run {cmd[0]}: {exc}')

    def install_apt(self, label, packages, reboot=False):
        pkg_text = ' '.join(packages)
        self.set_status(f'Opening installer for {label}...')
        command = (
            'set -e; '
            'echo "Installing ' + label.replace('"', '\\"') + '"; '
            'sudo apt-get update; '
            'sudo apt-get install -y ' + pkg_text + '; '
            'echo; echo "Done."; '
        )
        if reboot:
            command += 'echo "Reboot after installing the NVIDIA driver before gaming or testing performance."; '
        command += 'echo "Press Enter to close."; read _'
        terminal = shutil.which('x-terminal-emulator') or shutil.which('gnome-terminal')
        if terminal and terminal.endswith('gnome-terminal'):
            subprocess.Popen([terminal, '--', 'sh', '-lc', command])
        elif terminal:
            subprocess.Popen([terminal, '-e', 'sh', '-lc', command])
        else:
            subprocess.Popen(['pkexec', 'sh', '-lc', command])

    def show_nvidia_notice(self):
        dialog = Gtk.AlertDialog(
            message='NVIDIA GPU detected',
            detail='MI Linux can install the NVIDIA driver from the Welcome app. Install MI Linux first if you want the driver to persist, then click Install NVIDIA Driver and reboot.'
        )
        dialog.show(self.win)
        return False


if __name__ == '__main__':
    Welcome().run(None)
