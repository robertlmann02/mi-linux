#!/usr/bin/env python3
"""Simple GTK/GNOME MI Linux Update Manager for Founder Preview."""
import subprocess
import gi
gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, GLib

class UpdateManager(Gtk.Application):
    def __init__(self):
        super().__init__(application_id='org.mannindustries.MILinuxUpdateManager')

    def do_activate(self):
        win = Gtk.ApplicationWindow(application=self)
        win.set_title('MI Linux Update Manager')
        win.set_default_size(720, 480)
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        box.set_margin_top(18); box.set_margin_bottom(18); box.set_margin_start(18); box.set_margin_end(18)
        title = Gtk.Label(label='MI Linux Forky Founder updates')
        title.add_css_class('title-1')
        box.append(title)
        self.status = Gtk.Label(label='Channel: forky-founder\nPolicy: 3-month delayed MI Linux updates\nSecurity updates: automatic\nNon-security updates: approval required')
        self.status.set_xalign(0)
        box.append(self.status)
        for text, action in [
            ('Check for Updates', self.check_updates),
            ('Create Timeshift Snapshot', self.create_snapshot),
            ('Install Approved Non-Security Updates', self.install_updates),
            ('Show Security Status', self.security_status),
        ]:
            btn = Gtk.Button(label=text)
            btn.connect('clicked', action)
            box.append(btn)
        win.set_child(box)
        win.present()

    def run_cmd(self, cmd):
        try:
            out = subprocess.check_output(cmd, shell=True, text=True, stderr=subprocess.STDOUT, timeout=60)
        except Exception as e:
            out = str(e)
        self.status.set_text(out[:4000])

    def check_updates(self, *_):
        self.run_cmd('pkexec apt-get update && apt list --upgradable 2>/dev/null | head -100')

    def create_snapshot(self, *_):
        self.run_cmd('pkexec timeshift --create --comments "MI Linux pre-update snapshot" --tags D')

    def install_updates(self, *_):
        self.run_cmd('pkexec apt-get upgrade')

    def security_status(self, *_):
        self.run_cmd('systemctl is-active ufw; ufw status verbose; systemctl list-timers "mi-linux-*" --no-pager')

if __name__ == '__main__':
    app = UpdateManager()
    app.run(None)
