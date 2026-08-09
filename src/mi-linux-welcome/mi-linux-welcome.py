#!/usr/bin/env python3
"""Simple GTK/GNOME MI Linux Welcome app for Founder Preview."""
import gi, subprocess
gi.require_version('Gtk', '4.0')
from gi.repository import Gtk

RECOMMENDED = {
    'Browsers': ['Google Chrome', 'Microsoft Edge'],
    'Gaming': ['Steam', 'Lutris', 'Heroic Games Launcher', 'ProtonUp-Qt', 'OBS Studio', 'Discord'],
    'Windows Apps': ['Bottles', 'Wine', 'Winetricks', 'PlayOnLinux'],
    'Creative Tools': ['GIMP', 'Inkscape', 'Krita', 'Blender', 'Kdenlive', 'Audacity'],
    'Developer Tools': ['VS Code', 'VSCodium', 'Git', 'GitHub Desktop', 'Docker', 'Podman', 'Python tooling', 'Node.js tooling'],
    'Android Apps / Waydroid': ['Waydroid'],
    'Drivers / Hardware': ['NVIDIA Driver Installer'],
}

class Welcome(Gtk.Application):
    def __init__(self):
        super().__init__(application_id='org.mannindustries.MILinuxWelcome')
    def do_activate(self):
        win=Gtk.ApplicationWindow(application=self)
        win.set_title('Welcome to MI Linux')
        win.set_default_size(860, 640)
        scroll=Gtk.ScrolledWindow()
        box=Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        box.set_margin_top(18); box.set_margin_bottom(18); box.set_margin_start(18); box.set_margin_end(18)
        title=Gtk.Label(label='Welcome to MI Linux Forky Founder')
        title.add_css_class('title-1'); box.append(title)
        status=Gtk.Label(label='Security protection is active\nFirewall: On\nSecurity updates: On\nMalware scan schedule: On\nRootkit scan schedule: On')
        status.set_xalign(0); box.append(status)
        for label, cmd in [('Open Update Manager','mi-linux-update-manager'),('System Restore / Timeshift','timeshift-launcher'),('Open GNOME Software','gnome-software'),('Visit MI Linux Website','xdg-open https://mannindustries.org/mi-linux')]:
            b=Gtk.Button(label=label); b.connect('clicked', lambda _b,c=cmd: subprocess.Popen(c.split())) ; box.append(b)
        rec=Gtk.Label(label='Recommended Apps')
        rec.add_css_class('title-2'); box.append(rec)
        for cat, apps in RECOMMENDED.items():
            l=Gtk.Label(label=f'{cat}: ' + ', '.join(apps)); l.set_wrap(True); l.set_xalign(0); box.append(l)
        scroll.set_child(box); win.set_child(scroll); win.present()
if __name__ == '__main__': Welcome().run(None)
