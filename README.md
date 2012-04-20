ActionByNetwork
---------------

This script allows the user to configure various environments, identified by a wireless network SSID, in which certain scripts are run.

For example, when moving a personal laptop between home and work environments, Synergy keyboard and mouse sharing can be automated, as well as other variables set. In addition, when the computer connects to an unknown wifi network, such as in a coffee shop, SOCKS/proxy connections for privacy while surfing can be initiated automatically. (Currently there is no way to programatically enable and disable web proxies in browsers, so this still requires user intervention.)

Future versions will seek for better desktop environment integration (e.g. KDE 4.7 should add system-wide SOCKS proxy support). Current supported functionality includes:

* synergy connections

To do: 

* PID handling of parent script and various subscripts, for cleaner starts and stops
* Management of remote shares (including unmounting before disconnect to prevent D-state processes in file browsers)
* Management of SSH tunnels (primarily for SOCKS-based secure web browsing)
* Management of custom hosts files
* Add support for wired network connections
