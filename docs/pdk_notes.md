# Local Hardening for `ihp-sg13cmos5l` #

## Getting the PDK 
**Source: `install_sg13cmos5l.sh`, in the `ihp-cmos5l` branch of
[`TinyTapeout/tt-gds-action`](https://github.com/TinyTapeout/tt-gds-action)**

Because the `ihp-sg13cmos5l` PDK is new `ceil` doesn't recognizew it yet. So I cloned a specific version the PDK into my project's repository: 

```bash
mkdir -p ~/ttsetup/pdk-manual
cd ~/ttsetup/pdk-manual
git clone --branch dev --recurse-submodules https://github.com/IHP-GmbH/IHP-Open-PDK.git
cd IHP-Open-PDK
git clone https://github.com/IHP-GmbH/ihp-sg13cmos5l.git
cd ihp-sg13cmos5l
git checkout ae7613984daf3ac2b14897321399df497278068f  
```

## Debugging the PDK 

**Source: also `install_sg13cmos5l.sh`, same repo/branch as above.**

This script fixes three bugs in the PDK's own files:
 
1. A broken symlink: one file expected another file in a folder it had
   since moved out of.
2. Missing config lines 
3. A broken rule-checking file: referenced some files that don't exist
   for this PDK.

 All three fixes, copied directly from the script:
 
```bash
ln -sf openrcx/IHP_rcx_patterns.rules \
  ~/ttsetup/pdk-manual/IHP-Open-PDK/ihp-sg13g2/libs.tech/librelane/IHP_rcx_patterns.rules
 
python3 << 'PYEOF'
import pathlib
cfg = pathlib.Path("libs.tech/librelane/config.tcl")
text = cfg.read_text()
patch = "\n".join([
    '## magic setup',
    'set ::env(MAGICRC) "$::env(PDK_ROOT)/$::env(PDK)/libs.tech/magic/ihp-sg13cmos5l.magicrc"',
    'set ::env(MAGIC_TECH) "$::env(PDK_ROOT)/$::env(PDK)/libs.tech/magic/ihp-sg13cmos5l.tech"',
    '',
    '# netgen setup',
    'set ::env(NETGEN_SETUP) "$::env(PDK_ROOT)/$::env(PDK)/libs.tech/netgen/ihp-sg13cmos5l_setup.tcl"',
    '',
]) + "\n"
text = text.replace("# GPIO Pads", patch + "# GPIO Pads")
cfg.write_text(text)
 
drc = pathlib.Path("libs.tech/klayout/tech/drc/ihp-sg13cmos5l.drc")
drc_text = drc.read_text()
drc_text = "\n".join(
    line for line in drc_text.splitlines()
    if not ("%include rule_decks/" in line and "layers_def" not in line)
) + "\n"
drc.write_text(drc_text)
PYEOF
```
