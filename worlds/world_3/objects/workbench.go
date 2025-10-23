components {
  id: "craft_fx"
  component: "/assets/world_3/fx/checkup.particlefx"
  position {
    y: 90.0
    z: 1.0
  }
}
embedded_components {
  id: "left_hint"
  type: "sprite"
  data: "default_animation: \"element_iron\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/world_3/world_3.atlas\"\n"
  "}\n"
  ""
  position {
    x: -128.0
    y: 55.0
    z: 2.0
  }
}
embedded_components {
  id: "right_hint"
  type: "sprite"
  data: "default_animation: \"element_iron\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/world_3/world_3.atlas\"\n"
  "}\n"
  ""
  position {
    x: 128.0
    y: 55.0
    z: 2.0
  }
}
embedded_components {
  id: "result_hint"
  type: "sprite"
  data: "default_animation: \"element_iron\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "size {\n"
  "  x: 75.0\n"
  "  y: 75.0\n"
  "}\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/world_3/world_3.atlas\"\n"
  "}\n"
  ""
  position {
    y: 55.0
    z: 2.0
  }
}
embedded_components {
  id: "spinemodel"
  type: "spinemodel"
  data: "spine_scene: \"/assets/world_3/spine/buildings/workbench.spinescene\"\n"
  "default_animation: \"idle\"\n"
  "skin: \"\"\n"
  "material: \"/defold-spine/assets/spine.material\"\n"
  ""
}
