import * as THREE from "three"

const MOOD_COLORS = {
  happy: 0x34d399,
  annoyed: 0xfbbf24,
  sad: 0x60a5fa,
  neutral: 0x94a3b8
}

function moodColor(mood) {
  return MOOD_COLORS[mood] ?? MOOD_COLORS.neutral
}

function makeNpcMesh(name, mood) {
  const group = new THREE.Group()
  group.userData.kind = "npc"
  group.userData.name = name
  group.userData.baseY = 0.9

  const bodyMat = new THREE.MeshStandardMaterial({
    color: moodColor(mood),
    roughness: 0.55,
    metalness: 0.08
  })
  const body = new THREE.Mesh(new THREE.CapsuleGeometry(0.35, 0.85, 6, 12), bodyMat)
  body.position.y = 0.55
  body.castShadow = true
  group.add(body)

  const head = new THREE.Mesh(
    new THREE.SphereGeometry(0.28, 16, 12),
    new THREE.MeshStandardMaterial({ color: 0xf1f5f9, roughness: 0.4 })
  )
  head.position.y = 1.18
  head.castShadow = true
  group.add(head)

  return group
}

function makeBenchMesh() {
  const g = new THREE.Group()
  g.userData.kind = "bench"
  const wood = new THREE.MeshStandardMaterial({ color: 0x78350f, roughness: 0.85 })
  const seat = new THREE.Mesh(new THREE.BoxGeometry(2.2, 0.15, 0.75), wood)
  seat.position.y = 0.45
  seat.castShadow = true
  g.add(seat)
  const back = new THREE.Mesh(new THREE.BoxGeometry(2.2, 0.85, 0.12), wood)
  back.position.set(0, 0.9, -0.35)
  back.castShadow = true
  g.add(back)
  const legMat = new THREE.MeshStandardMaterial({ color: 0x44403c, roughness: 0.7 })
  ;[[-0.9, 0.2, 0.25], [0.9, 0.2, 0.25], [-0.9, 0.2, -0.25], [0.9, 0.2, -0.25]].forEach(
    ([x, y, z]) => {
      const leg = new THREE.Mesh(new THREE.CylinderGeometry(0.06, 0.07, 0.4, 8), legMat)
      leg.position.set(x, y, z)
      leg.castShadow = true
      g.add(leg)
    }
  )
  return g
}

function makeCrateMesh() {
  const mesh = new THREE.Mesh(
    new THREE.BoxGeometry(0.85, 0.85, 0.85),
    new THREE.MeshStandardMaterial({ color: 0xa8a29e, roughness: 0.65 })
  )
  mesh.position.y = 0.45
  mesh.castShadow = true
  const g = new THREE.Group()
  g.userData.kind = "crate"
  g.add(mesh)
  return g
}

function makeFountainMesh() {
  const g = new THREE.Group()
  g.userData.kind = "fountain"
  const basin = new THREE.Mesh(
    new THREE.CylinderGeometry(1.1, 1.25, 0.35, 24),
    new THREE.MeshStandardMaterial({ color: 0x64748b, roughness: 0.35, metalness: 0.15 })
  )
  basin.position.y = 0.2
  basin.castShadow = true
  g.add(basin)
  const rim = new THREE.Mesh(
    new THREE.TorusGeometry(1.05, 0.08, 10, 32),
    new THREE.MeshStandardMaterial({ color: 0x94a3b8, roughness: 0.4 })
  )
  rim.rotation.x = Math.PI / 2
  rim.position.y = 0.38
  g.add(rim)
  const water = new THREE.Mesh(
    new THREE.CircleGeometry(0.95, 32),
    new THREE.MeshStandardMaterial({
      color: 0x38bdf8,
      roughness: 0.15,
      metalness: 0.2,
      transparent: true,
      opacity: 0.82
    })
  )
  water.rotation.x = -Math.PI / 2
  water.position.y = 0.36
  g.add(water)
  return g
}

function itemMeshForEntry(data) {
  const id = String(data.id || "")
  if (data.type === "bench") return makeBenchMesh()
  if (data.type === "object" && id.includes("fountain")) return makeFountainMesh()
  return makeCrateMesh()
}

function zoneTint(id) {
  switch (id) {
    case "square":
      return 0x1e293b
    case "shop":
      return 0x292524
    case "park":
      return 0x14532d
    case "tavern":
      return 0x3b0764
    default:
      return 0x0f172a
  }
}

export const TownSquare3D = {
  mounted() {
    this.npcNodes = new Map()
    this.itemNodes = new Map()
    this.npcTargets = new Map()
    this.resizeObserver = null

    const el = this.el
    const w = el.clientWidth || 640
    const h = el.clientHeight || 320

    this.scene = new THREE.Scene()
    this.scene.background = new THREE.Color(0x020617)

    this.camera = new THREE.PerspectiveCamera(50, w / h, 0.1, 200)
    this.camera.position.set(0, 18, 18)
    this.camera.lookAt(0, 0, 0)

    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false })
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2))
    this.renderer.setSize(w, h)
    this.renderer.shadowMap.enabled = true
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap
    el.appendChild(this.renderer.domElement)

    const hemi = new THREE.HemisphereLight(0xbfd7ff, 0x222222, 0.55)
    this.scene.add(hemi)
    const sun = new THREE.DirectionalLight(0xffffff, 0.95)
    sun.position.set(10, 22, 8)
    sun.castShadow = true
    sun.shadow.mapSize.set(2048, 2048)
    sun.shadow.camera.near = 0.5
    sun.shadow.camera.far = 60
    sun.shadow.camera.left = -22
    sun.shadow.camera.right = 22
    sun.shadow.camera.top = 22
    sun.shadow.camera.bottom = -22
    this.scene.add(sun)

    this.groundGroup = new THREE.Group()
    this.scene.add(this.groundGroup)

    this.handleEvent("scene_init", (payload) => this.applyInit(payload))
    this.handleEvent("scene_patch", (payload) => this.applyPatch(payload))

    this._tick = () => {
      this.stepTween()
      this.renderer.render(this.scene, this.camera)
      this.raf = requestAnimationFrame(this._tick)
    }
    this.raf = requestAnimationFrame(this._tick)

    this.resizeObserver = new ResizeObserver(() => this.onResize())
    this.resizeObserver.observe(el)
  },

  updated() {},

  destroyed() {
    if (this.resizeObserver) this.resizeObserver.disconnect()
    cancelAnimationFrame(this.raf)
    this.renderer.dispose()
    this.el.removeChild(this.renderer.domElement)
  },

  onResize() {
    const el = this.el
    const w = el.clientWidth
    const h = el.clientHeight
    if (w <= 0 || h <= 0) return
    this.camera.aspect = w / h
    this.camera.updateProjectionMatrix()
    this.renderer.setSize(w, h)
  },

  clearEntities() {
    for (const g of this.npcNodes.values()) this.scene.remove(g)
    for (const g of this.itemNodes.values()) this.scene.remove(g)
    this.npcNodes.clear()
    this.itemNodes.clear()
    this.npcTargets.clear()
    this.groundGroup.clear()
  },

  buildGround(zones) {
    const base = new THREE.Mesh(
      new THREE.PlaneGeometry(42, 42),
      new THREE.MeshStandardMaterial({ color: 0x0b1222, roughness: 0.95 })
    )
    base.rotation.x = -Math.PI / 2
    base.receiveShadow = true
    this.groundGroup.add(base)

    for (const z of zones || []) {
      const plane = new THREE.Mesh(
        new THREE.PlaneGeometry(z.size - 0.2, z.size - 0.2),
        new THREE.MeshStandardMaterial({
          color: zoneTint(z.id),
          roughness: 0.92,
          transparent: true,
          opacity: 0.92
        })
      )
      plane.rotation.x = -Math.PI / 2
      plane.position.set(z.origin.x + z.size / 2, 0.02, z.origin.z + z.size / 2)
      plane.receiveShadow = true
      this.groundGroup.add(plane)
    }
  },

  applyInit(payload) {
    this.clearEntities()
    this.buildGround(payload.zones)
    for (const n of payload.npcs || []) this.upsertNpc(n, true)
    for (const it of payload.items || []) this.upsertItem(it, true)
  },

  applyPatch(payload) {
    for (const n of payload.npcs || []) this.upsertNpc(n, false)
    for (const it of payload.items || []) this.upsertItem(it, false)
    const inter = payload.interact
    if (inter) this.playInteract(inter)
  },

  upsertNpc(data, snap) {
    const id = data.id
    let group = this.npcNodes.get(id)
    if (!group) {
      group = makeNpcMesh(data.name, data.mood)
      this.scene.add(group)
      this.npcNodes.set(id, group)
    }
    group.userData.mood = data.mood
    const mat = group.children[0]?.material
    if (mat && mat.color) mat.color.setHex(moodColor(data.mood))

    const tx = data.x
    const ty = data.y
    const tz = data.z
    if (snap || !this.npcTargets.has(id)) {
      group.position.set(tx, ty, tz)
    }
    this.npcTargets.set(id, { x: tx, y: ty, z: tz })
  },

  upsertItem(data, snap) {
    const id = data.id
    let group = this.itemNodes.get(id)
    if (!group) {
      group = itemMeshForEntry(data)
      this.scene.add(group)
      this.itemNodes.set(id, group)
    }
    group.position.set(data.x, 0, data.z)
    group.userData.state = data.state
    group.visible = data.state !== "taken"
    this.applyItemVisual(group, data.state, snap)
  },

  applyItemVisual(group, state, _snap) {
    const kind = group.userData.kind
    group.children.forEach((ch) => {
      if (ch.material && ch.material.emissive) {
        ch.material.emissive.setHex(0x000000)
        ch.material.emissiveIntensity = 0
      }
    })
    if (kind === "bench" && state === "in_use") {
      group.children.forEach((ch) => {
        if (ch.material && ch.material.emissive) {
          ch.material.emissive.setHex(0xf59e0b)
          ch.material.emissiveIntensity = 0.35
        }
      })
    }
  },

  playInteract(inter) {
    const npc = this.npcNodes.get(inter.npcId)
    const item = this.itemNodes.get(inter.itemId)
    if (!npc || !item) return

    if (inter.effect === "sat_down") {
      const ix = item.position.x
      const iz = item.position.z
      npc.position.x = ix + 0.15
      npc.position.z = iz + 0.35
      npc.position.y = 0.35
      this.npcTargets.set(inter.npcId, { x: ix + 0.15, y: 0.35, z: iz + 0.35 })
    } else if (inter.effect === "picked_up") {
      item.visible = false
    }
  },

  stepTween() {
    const alpha = 0.12
    for (const [id, group] of this.npcNodes) {
      const t = this.npcTargets.get(id)
      if (!t) continue
      group.position.x += (t.x - group.position.x) * alpha
      group.position.y += (t.y - group.position.y) * alpha
      group.position.z += (t.z - group.position.z) * alpha
    }
  }
}
