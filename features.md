# Features
This is a list of features, systems, etc that hacker core should have, with checkboxes for some. Think standard subset: useful to just about everybody making anything in moo. Ok but also cool things you've made and want to show off, useful utilities, code you can't live in a core without.
Note that these don't need to specifically be the lambda core versions of these things, though often they'll likely be the cannonical / early version.

## Choices
* Created players as anonymous objects - this sets them aside in an easily ignorable file, and as long as no numbered object holds a reference to one they're out of dumps, in theory anyway.

## objects
* root object (discuss specifics below)
* player class
* room
* room detail - stationary "object" (probably anon) which can be looked at and otherwise interacted with in a room
* area
* exit
* thing
* container
* note
* book - multi-page readable/writable with table of contents, locking, page tearing
* letter
* Avatar - likely descendant of player class, aka puppet, simulated player - controllable by others
* consumable (generic food  / drink)?
* clothing - wearable items
* furniture - sittable/usable room objects
* door - lockable passages between rooms
* breakable detail - destructible room features
* Non-wizard code owner: $hacker (#36)
* npc - non-player character base class

## Systems
* [x] Simple stable heart for periodically running tasks from progs or wizards as desired
* [x] Precise scheduler (as far as moo can get anyway) with cron syntax
* [x?] An optional recycler / objid allocation pool object
* [x] Spellchecker (telnet folks) - "Mr. Spell" with dictionary and validation
* [ ] Channels - multi-user chat with history, moderation, filters
* [?] long-term / asynchronous messages - was moomail in lambdacore
* Room / personal replay (think moor does something for this?)
  * Should be configurable whether this persists when disconnected, in case user / future cores don't want
* [ ] code / version management: in progress with VCS feature and worker
* [x] Wizard utilities - enhanced server builtins for ownership, permissions
* Help system: help databases for sets of commands; .help_msg or :help_msg for matched objects
* [x] Generic editor system - inline text editing for various objects
* [x] Area management - grouped rooms with navigation and utilities
* [x] Module system - extensible room and object behaviors
* [x] Core integrity checking - database comparison and hash verification
* [ ] SQL/SQLite integration - database persistence and queries
* [x] MCP (MOO Client Protocol) - enhanced client communication
* [x] Octree spatial indexing - efficient 3D object organization
* [x] Social system - emotes and interaction commands

## Utility Libraries
* [x] String utilities - text manipulation and formatting
* [x] List utilities - list operations and transformations
* [x] Map utilities - k/v operations
* [x] Web utilities - HTTP/web development helpers
* [x] Mapping utilities - coordinate and spatial functions
* [x] PC (player character) utilities - character management
* [x] Menu utilities - interactive menu systems
* [x] Telnet utilities - telnet protocol handling
* [x] WebSocket utilities - should be made into parse and construct builtins

## Specialized Features
* [x] Trace system - debugging and execution tracking
* [x] Options framework - user preference management
* [x] Synchronizer - cross-server data synchronization


# Requirements of the root object
* :announce_event(), :_handlers() - support for events


# Thoughts on avatars
These should have verbs for do_say, do_tell, do_yell, etc, and the player class should be a descendant, allowing for easy NPC creation. I called it $beeing on ChatMUD and maybe that's a better name than avatar. The idea is to share as much code between players and npcs as possible. The player class will have the actual human commands which call the do_x verbs on `this`.

