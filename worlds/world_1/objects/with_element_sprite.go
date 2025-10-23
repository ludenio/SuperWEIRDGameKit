embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"store\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/world_1/world_1.atlas\"\n"
  "}\n"
  ""
}
embedded_components {
  id: "element_sprite"
  type: "sprite"
  data: "default_animation: \"element_stone\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/world_1/world_1.atlas\"\n"
  "}\n"
  ""
  position {
    y: 200.0
    z: 2.0
  }
  scale {
    x: 0.5
    y: 0.5
  }
}
