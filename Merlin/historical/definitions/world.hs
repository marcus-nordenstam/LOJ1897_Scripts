; world.hs - default world for the standalone hsim_world app.
;
; When hsim_world runs with NO command-line args it reads this file and
; materialises the named .mwo against the given content root. Override either
; value on the command line with --mwo <path> / --content <dir>, or point at a
; different config with --world-cfg <path>.
;
; Both paths are absolute. The .mob kind sidecars are picked up automatically
; from the same folder as the .mwo (Content/Environment/Merlin). The .ter is
; resolved as <content>/<terrain-ref-stored-in-the-.mwo>.

(mwo     "C:/Users/realm/Dropbox/CnE/LOJ1897/Game/Content/Environment/Merlin/demo_tech_level_v2.mwo")
(content "C:/Users/realm/Dropbox/CnE/LOJ1897/Game/Content")
