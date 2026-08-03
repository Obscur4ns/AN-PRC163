# Third-Party Notices

This document records dependencies, compatibility targets, trademarks, and material that may be subject to licences other than the UKSF AN/PRC-163 public licence.

It is not a substitute for a file-by-file provenance audit.

## 1. ACRE2

Project:

- Advanced Combat Radio Environment 2
- Official repository: https://github.com/IDI-Systems/acre2
- Core licence: GNU General Public License version 3

The UKSF AN/PRC-163 is designed to operate through ACRE2 and references ACRE2 classes, functions, interfaces, radio modes, racks, antennas, and APIs.

Mere dependency declarations and calls to ACRE2 interfaces do not transfer ownership of ACRE2 to this project.

Any ACRE2 source code or assets copied or adapted into the PRC-163 project remain subject to the applicable ACRE2 licence and any more specific licence supplied in the relevant ACRE2 folder.

Before release, review every file derived from an ACRE2 implementation and add a file-level notice where required.

## 2. CBA_A3

Project:

- Community Base Addons for Arma 3
- Official repository: https://github.com/CBATeam/CBA_A3
- Licence: GNU General Public License version 2

The addon uses CBA functions, keybindings, settings, and per-frame handlers.

CBA's published licence guidance states that an addon which only calls CBA-defined functions need not itself be licensed under GPLv2. Direct inclusion or modification of CBA code is different and must follow CBA's licence.

## 3. ACE3

Project:

- Advanced Combat Environment 3
- Official repository: https://github.com/acemod/ACE3
- Core licence: GNU General Public License version 2 or, at the recipient's option, a later version
- Some ACE3 folders contain separate licences

The addon uses ACE interaction and UI functionality.

Any ACE3 code or assets copied or adapted into this project remain subject to their applicable ACE3 or folder-specific licence.

## 4. Arma and Bohemia Interactive

Arma, Arma 3, and associated names and assets are owned by Bohemia Interactive.

The public licence selected for original UKSF AN/PRC-163 material is the Arma Public License No Derivatives:

https://www.bohemia.net/en/licenses/arma-public-license-nd

No ownership of Arma or Bohemia Interactive material is claimed.

## 5. L3Harris and AN/PRC-163 references

L3Harris, L3HARRIS, Falcon, Falcon IV, AN/PRC-163, associated logos, product appearances, and related branding may be trademarks, trade dress, or other protected material belonging to their respective owners.

The project currently references an asset at:

```text
data\ui\l3harris_logo.paa
```

The APL-ND notice for original UKSF material does not grant rights in the L3Harris logo or branding.

Before public release, the project owner should confirm that use and distribution of this logo asset is authorised, replace it with original non-infringing artwork, or remove it.

No affiliation with or endorsement by L3Harris Technologies is claimed.

## 6. Models, textures, icons, and sounds

Before release, confirm and record the provenance of at least:

```text
data\prc163.p3d
data\battery.p3d
data\ui\l3harris_logo.paa
all PAA textures
all inventory and editor icons
all sound assets
```

For each asset, record:

- creator;
- copyright holder;
- source;
- date obtained;
- licence or written permission;
- whether modification and redistribution are permitted;
- whether source files may be distributed.

An asset is not covered by the UKSF APL-ND notice merely because it is stored inside the project folder.

## 7. Channel-name addon

The optional unit channel-name addon is separate from the core PRC-163.

Its configuration, names, and assets should carry their own licence notice and should not be assumed to fall under this package.

## 8. Dependency versus inclusion

The following normally indicate a dependency rather than inclusion:

- `requiredAddons[]` entries;
- inheritance from an external config class;
- calls to public functions;
- use of documented APIs;
- references to external class names.

The following require closer licence review:

- copied function bodies;
- copied UI definitions;
- copied textures or models;
- modified upstream source files;
- bundled third-party PBOs;
- extracted or converted game data.

## 9. Release audit checklist

Before release:

1. Search source headers and comments for upstream copyright notices.
2. Compare adapted functions against their ACRE2, ACE3, and CBA sources.
3. Identify every non-original model, texture, icon, logo, and sound.
4. Retain required notices in source and release packages.
5. Include complete licence texts where an upstream licence requires them.
6. Ensure no third-party material is incorrectly described as APL-ND.
7. Confirm the public Workshop description links to the licence documents.
8. Have uncertain ownership or relicensing questions reviewed by a qualified intellectual-property solicitor.

## 10. No endorsement

The UKSF AN/PRC-163 project is not endorsed by or affiliated with Bohemia Interactive, L3Harris Technologies, ACRE2, ACE3 or CBA_A3 unless an authorised representative expressly states otherwise.
