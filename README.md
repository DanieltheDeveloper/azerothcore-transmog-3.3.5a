# Do you want to support the continuation of this and other projects?
Visit my Patreon page [here](https://patreon.com/danielthedeveloper) and show your support!

<br>
<br>

# AzerothCore Transmog System 3.3.5a

Transmog system created with AIO and Eluna for AzerothCore.

## Installation

- Make sure you have [AIO](https://github.com/Rochet2/AIO) and [Eluna](https://github.com/azerothcore/mod-eluna) on your server/AzerothCore.
- Put the contents of the lua_scripts folder inside your lua scripts folder you created for Eluna/AIO
- Import the sql files inside the sql folder
- Move the patch files into a patch.mpq of your choosing. Use MPQEditor for example
- Start your server and have fun!

For help read the mod-eluna documentation for AzerothCore [here](https://github.com/azerothcore/mod-eluna)

## Know Bugs: Currently under development

- Currently, the real_item id is removed from the database and the transmog is broken by first resetting and then deleting the slot or slots
- The click area is off-center because the UI button for deletion and reset is not properly centered.

## WIP

- Spam prevention (click events)
- Display small info text on items if you have previously obtained the transmog/display id
- Search with display id
- Weapon auras
- Spells/Character effects

<br>
<br>

![alt text](./Screenshot.png)
![alt text 2](./Screenshot2.png)
