embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"foundation\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/world_5/world_5.atlas\"\n"
  "}\n"
  ""
  position {
    y: 27.0
  }
}
embedded_components {
  id: "price"
  type: "label"
  data: "size {\n"
  "  x: 128.0\n"
  "  y: 32.0\n"
  "}\n"
  "pivot: PIVOT_E\n"
  "text: \"Label\"\n"
  "font: \"/builtins/fonts/default.font\"\n"
  "material: \"/builtins/fonts/label-df.material\"\n"
  ""
  position {
    x: -1.0
    y: 55.0
    z: 2.0
  }
  scale {
    x: 1.5
    y: 1.5
  }
}
embedded_components {
  id: "coin_icon"
  type: "sprite"
  data: "default_animation: \"coin\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/world_5/world_5.atlas\"\n"
  "}\n"
  ""
  position {
    x: 19.0
    y: 45.0
    z: 2.0
  }
  scale {
    x: 0.4
    y: 0.4
  }
}
embedded_components {
  id: "bounds"
  type: "sprite"
  data: "default_animation: \"bounds_small\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/world_5/world_5.atlas\"\n"
  "}\n"
  ""
}
