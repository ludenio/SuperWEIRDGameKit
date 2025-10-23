components {
  id: "spawn_fx"
  component: "/assets/world_4/fx/spawn.particlefx"
  position {
    y: 75.0
    z: 0.1
  }
}
embedded_components {
  id: "spinemodel"
  type: "spinemodel"
  data: "spine_scene: \"/assets/world_4/spine/characters/main.spinescene\"\n"
  "default_animation: \"idle\"\n"
  "skin: \"\"\n"
  "material: \"/defold-spine/assets/spine.material\"\n"
  "create_go_bones: true\n"
  ""
}
