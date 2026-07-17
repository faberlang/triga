import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

const sceneUrl = new URL('./triga-scene.json', import.meta.url);
const response = await fetch(sceneUrl);
if (!response.ok) {
  throw new Error(`Unable to load ${sceneUrl}: ${response.status}`);
}
const trigaScene = await response.json();

const canvas = document.querySelector('#triga-canvas');
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.setClearColor(0x10131a, 1);

const threeScene = new THREE.Scene();
threeScene.name = trigaScene.schema;
threeScene.add(new THREE.AmbientLight(0xffffff, 0.55));

const geometryById = new Map(
  trigaScene.geometries.map((geometry) => [geometry.id, toThreeGeometry(geometry)]),
);
const materialById = new Map(
  trigaScene.materials.map((material) => [material.id, toThreeMaterial(material)]),
);
const objectByIndex = new Map();

for (const node of trigaScene.nodes) {
  const object = toThreeObject(node, geometryById, materialById);
  object.name = `${node.name} [${node.handle.index}:${node.handle.generation}]`;
  object.matrixAutoUpdate = false;
  object.matrix.fromArray(node.localMatrix);
  objectByIndex.set(node.handle.index, object);
}

for (const node of trigaScene.nodes) {
  const object = objectByIndex.get(node.handle.index);
  if (node.parent === null) {
    threeScene.add(object);
  } else {
    objectByIndex.get(node.parent).add(object);
  }
}

const camera = new THREE.PerspectiveCamera(
  trigaScene.camera.fov,
  canvas.clientWidth / Math.max(canvas.clientHeight, 1),
  trigaScene.camera.near,
  trigaScene.camera.far,
);
camera.matrix.fromArray(trigaScene.camera.localMatrix);
camera.matrix.decompose(camera.position, camera.quaternion, camera.scale);
camera.lookAt(new THREE.Vector3(...trigaScene.camera.lookAt));
camera.updateMatrix();

const controls = new OrbitControls(camera, renderer.domElement);
controls.target.set(...trigaScene.camera.lookAt);
controls.enableDamping = true;

const axes = new THREE.AxesHelper(2.5);
axes.name = 'world axes';
threeScene.add(axes);
const grid = new THREE.GridHelper(6, 6, 0x4f637d, 0x273142);
grid.name = 'world grid';
threeScene.add(grid);

const facts = document.querySelector('#facts');
facts.replaceChildren(
  ...trigaScene.source.sceneFacts.map((fact) => {
    const item = document.createElement('li');
    item.textContent = fact;
    return item;
  }),
);

function toThreeGeometry(geometry) {
  const threeGeometry = new THREE.BufferGeometry();
  for (const [name, attribute] of Object.entries(geometry.attributes)) {
    threeGeometry.setAttribute(
      name,
      new THREE.BufferAttribute(new Float32Array(attribute.values), attribute.componentWidth),
    );
  }
  threeGeometry.setIndex(geometry.indices);
  threeGeometry.computeBoundingBox();
  threeGeometry.computeBoundingSphere();
  if (!threeGeometry.attributes.normal) {
    threeGeometry.computeVertexNormals();
  }
  return threeGeometry;
}

function toThreeMaterial(material) {
  return new THREE.MeshStandardMaterial({
    color: material.color,
    roughness: material.roughness,
    metalness: material.metalness,
    side: THREE.DoubleSide,
  });
}

function toThreeObject(node, geometryById, materialById) {
  if (node.kind === 'mesh') {
    const mesh = new THREE.Mesh(
      geometryById.get(node.geometry),
      materialById.get(node.material),
    );
    mesh.castShadow = true;
    mesh.receiveShadow = true;
    return mesh;
  }
  if (node.kind === 'directional-light') {
    return new THREE.DirectionalLight(node.color, node.intensity);
  }
  return new THREE.Group();
}

function resizeRenderer() {
  const width = canvas.clientWidth;
  const height = canvas.clientHeight;
  const needsResize = canvas.width !== Math.floor(width * renderer.getPixelRatio())
    || canvas.height !== Math.floor(height * renderer.getPixelRatio());
  if (needsResize) {
    renderer.setSize(width, height, false);
    camera.aspect = width / Math.max(height, 1);
    camera.updateProjectionMatrix();
  }
}

function animate() {
  resizeRenderer();
  controls.update();
  renderer.render(threeScene, camera);
  requestAnimationFrame(animate);
}

animate();
