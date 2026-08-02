# UKSF AN/PRC-163 for ACRE2

A custom AN/PRC-163 radio addon for Arma 3 and ACRE2, developed for Z Squadron UKSF mil-sim use.

The addon provides two independently configurable radio lines inside one physical radio, allowing the player to monitor and transmit on two channels while retaining native ACRE interaction patterns.

## Features

- Two independent radio lines:
  - R/T 1
  - R/T 2
- Dual Watch operation
- Standard ACRE PTT transmits on the currently selected R/T
- Native ACRE PTT 1 and PTT 2 support
- Independent channel, volume and audio routing per R/T
- LEFT, RIGHT or BOTH ear routing per line
- Independent TX power settings
- Authentic AN/PRC-163-style HMI
- Startup and shutdown sequence
- Persistent battery system
- Replaceable PRC-163 batteries
- Low-battery warning tone
- ACE self-interaction support
- Ground Spike and Ground Spike Mast compatibility
- Eden and Zeus placeable radio and battery objects
- Multiplayer-compatible transmission and reception

## Requirements

The addon requires:

- Arma 3
- CBA_A3
- ACRE2
- ACE3

The configuration explicitly depends on the following components:

- `cba_common`
- `cba_keybinding`
- `cba_settings`
- `acre_sys_modes`
- `acre_sys_prc152`
- `acre_sys_antenna`
- `ace_common`
- `ace_interact_menu`

## Installation

1. Place the packed addon inside an Arma 3 mod folder.
2. Load CBA_A3, ACRE2 and ACE3 before the PRC-163 addon.
3. Ensure the ACRE2 TeamSpeak plugin is installed and enabled.
4. Add the mod to both clients and the server for multiplayer use.

## Using the Radio

The usable inventory radio class is:

```text
ACRE_PRC163
```

The replacement battery class is:

```text
UKSF_PRC163_Battery
```

The radio can be opened through the usual ACRE or ACE interaction methods.

## R/T 1 and R/T 2

One physical PRC-163 contains two internal ACRE endpoints.

Each R/T stores its own:

- preset
- frequency
- volume
- ear routing
- transmit power
- transmission state

Changing a setting on one R/T does not alter the other.

## Selecting an R/T

The selected R/T controls:

- the line shown as active on the HMI
- the line used by standard ACRE PTT
- the line available when Dual Watch is disabled

R/T selection can be changed through the radio HMI or the configured external controls.

## Push-to-Talk

### Standard ACRE PTT

Standard PTT transmits on the currently selected R/T.

### ACRE PTT 1

ACRE PTT 1 transmits on R/T 1.

### ACRE PTT 2

ACRE PTT 2 transmits on R/T 2.

Dedicated PTT controls do not change the R/T selected on the HMI.

All PTT controls use press-and-hold behaviour.

## Dual Watch

### Dual Watch On

Both R/T endpoints can receive independently.

Example:

```text
R/T 1 — Channel A — LEFT
R/T 2 — Channel B — RIGHT
```

A transmission on Channel A is heard through the left ear, while a transmission on Channel B is heard through the right ear.

### Dual Watch Off

Only the currently selected R/T receives.

The inactive R/T retains its configuration but is muted until it is selected or Dual Watch is enabled again.

Dedicated ACRE PTT 1 and PTT 2 remain available for deliberate transmission on either line.

## HMI

The radio interface includes:

- Home
- Main Menu
- R/T Select
- Preset
- Volume
- Audio
- Status
- TX Power

The channel knob can be rotated backwards from `P01` to `OFF`.

When powered on, the radio displays the startup sequence before becoming available.

## Presets

Each R/T supports up to 99 presets.

Preset names may be supplied by a separate optional channel-name addon. When no custom name is available, the radio falls back to preset and frequency information.

The core PRC-163 addon does not hardcode unit-specific channel names.

## Audio Routing

Each R/T can be routed independently to:

- LEFT
- RIGHT
- BOTH

This supports monitoring up to four separated channels when using a PRC-163 alongside another multi-channel radio setup.

## Volume

Volume is stored separately for R/T 1 and R/T 2.

Changing the volume on one line does not affect the other.

## TX Power and Range

The HMI writes native ACRE channel power values.

A displayed setting of `5 W` is stored as:

```text
5000 mW
```

Actual range is controlled by ACRE2 and varies with:

- terrain
- elevation
- line of sight
- antenna type
- antenna orientation
- propagation model
- terrain-loss settings
- map compatibility data

The addon does not impose a fixed distance cutoff.

For realistic results, use ACRE's LOS Multipath propagation model and test radio performance against the native ACRE PRC-152 on the same terrain.

## Ground Spike Antennas

The PRC-163 supports:

- ACRE Ground Spike
- ACRE Ground Spike with Mast

The compatible antenna components are:

```text
ACRE_243CM_VHF_TNC
ACRE_643CM_VHF_TNC
```

The radio inherits a TNC antenna interface from the ACRE PRC-152 component.

## Battery System

Each physical PRC-163 has its own battery state.

Battery behaviour includes:

- gradual drain
- persistent charge state
- per-radio serial tracking
- automatic shutdown at depletion
- low-battery warning tone
- ACE self-interaction battery check
- in-game battery replacement

Battery state is saved per player and restored across supported sessions.

## Battery Replacement

Carry a spare:

```text
UKSF_PRC163_Battery
```

Use the ACE interaction on the radio to check or replace the battery.

Replacement creates a new battery record for that radio and restores operation.

## Notifications

Native ACRE notifications are used for:

- channel changes
- direct preset changes
- R/T selection
- transmission feedback

PRC-163-specific notifications are used for:

- power state
- invalid preset entry
- battery warnings
- battery replacement
- status information
- external Dual Watch changes

The PRC-specific notification position can be adjusted through:

```text
Options
Game
Layout
PRC-163 Notifications
```

## World Objects

The addon provides placeable Eden and Zeus objects:

```text
UKSF_PRC163_World
UKSF_PRC163_Battery_World
```

Both objects use dedicated world models and can be picked up into the player's inventory.

## Multiplayer

The radio is designed for multiplayer use with ACRE2.

Verified multiplayer behaviour includes:

- reception on both R/T lines
- transmission through standard ACRE PTT
- transmission through ACRE PTT 1
- transmission through ACRE PTT 2
- strict per-endpoint Dual Watch reception
- independent left/right ear routing
- Ground Spike and mast connection

All players and the server should use matching versions of the addon and its dependencies.

## Known Limitations

- Radio range varies significantly between terrains because ACRE uses terrain and propagation data rather than a fixed range.
- Simultaneous two-line operation depends on ACRE2 and its TeamSpeak plugin functioning correctly.
- Unit-specific preset names require a separate optional channel-name addon.
- Final compatibility may vary with custom maps that do not provide complete ACRE terrain data.

## Development and Packaging

The addon is intended to be packed using Mikero PBOProject.

Project root:

```text
P:\UKSF_PRC163
```

Before release:

1. Build the addon with required dependencies loaded.
2. Check the RPT for config, script and missing-resource errors.
3. Test one and two physical PRC-163 radios.
4. Test standard PTT, PTT 1 and PTT 2 in multiplayer.
5. Test Dual Watch on and off.
6. Test LEFT, RIGHT and BOTH routing.
7. Test battery drain, depletion, persistence and replacement.
8. Test Ground Spike and Ground Spike Mast connection.
9. Test dropped world objects and pickup.
10. Test radio range against the native ACRE PRC-152 on at least one official terrain.

## Credits

Developed for Z Squadron UKSF milsim.

Built for use with:

- Arma 3
- ACRE2
- CBA_A3
- ACE3
