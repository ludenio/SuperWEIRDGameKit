components {
  id: "spawn_fx"
  component: "/assets/world_1/fx/spawn.particlefx"
  position {
    y: 94.0
    z: 0.1
  }
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"element_stone\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/world_1/world_1.atlas\"\n"
  "}\n"
  ""
  position {
    y: 204.0
  }
  scale {
    x: 0.5
    y: 0.5
    z: 0.5
  }
}
embedded_components {
  id: "debug_label"
  type: "label"
  data: "size {\n"
  "  x: 128.0\n"
  "  y: 32.0\n"
  "}\n"
  "font: \"/builtins/fonts/default.font\"\n"
  "material: \"/builtins/fonts/label-df.material\"\n"
  ""
  position {
    y: 241.0
  }
}
embedded_components {
  id: "spinemodel"
  type: "spinemodel"
  data: "spine_scene: \"/assets/world_1/spine/characters/customer.spinescene\"\n"
  "default_animation: \"walkHappy\"\n"
  "skin: \"\"\n"
  "material: \"/defold-spine/assets/spine.material\"\n"
  "create_go_bones: true\n"
  ""
  scale {
    x: 0.8
    y: 0.8
  }
}
