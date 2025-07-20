const rl = @import("raylib");

pub fn main() anyerror!void {
    // Initialization
    //-------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "An army marches on it's stomach");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second

    // Setup camera

    const cameraPosition: rl.Vector3 = .{ .x = 0, .y = 21, .z = 18 };
    const cameraTarget: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 };
    const cameraUp: rl.Vector3 = .{ .x = 0, .y = 1, .z = 0 };
    const cameraProjection = rl.CameraProjection.perspective;
    var camera = rl.Camera{
        .fovy = 45.0,
        .position = cameraPosition,
        .up = cameraUp,
        .projection = cameraProjection,
        .target = cameraTarget,
    };

    // Setup terrain texture
    const image: rl.Image = try rl.loadImage("resources/heightmap.png");

    const texture: rl.Texture2D = try rl.loadTextureFromImage(image);
    defer rl.unloadTexture(texture);

    const meshSize = rl.Vector3{ .x = 16, .y = 8, .z = 16 };
    const mesh = rl.genMeshHeightmap(image, meshSize);
    defer rl.unloadMesh(mesh);

    var model = try rl.loadModelFromMesh(mesh);
    model.materials[0].maps[@intFromEnum(rl.MATERIAL_MAP_DIFFUSE)].texture = texture;

    const mapPosition = rl.Vector3{ .x = -8.0, .y = 0.0, .z = -8.0 };

    rl.unloadImage(image);

    //-------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //---------------------------------------------------------------------
        // TODO: Update your variables here
        //---------------------------------------------------------------------

        update(&camera);
        rl.updateCamera(&camera, .custom);

        // Draw
        //---------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        // Draw 3D

        rl.beginMode3D(camera);

        rl.drawModel(model, mapPosition, 1, .green);
        rl.drawGrid(20, 1.0);

        rl.endMode3D();

        rl.drawTexture(texture, screenWidth - texture.width - 20, 20, .white);
        rl.drawRectangleLines(screenWidth - texture.width - 20, 20, texture.width, texture.height, .green);
        rl.drawFPS(10, 10);

        rl.drawText("Marching Stomachs", 190, 200, 20, .light_gray);
        //---------------------------------------------------------------------
    }
}

pub fn update(camera: *rl.Camera3D) void {
    var move = rl.Vector3.zero();

    // x is -x left / +x right
    // y is up / down
    // z is -z forward / +z backward

    if (rl.isKeyDown(.w)) move.z = move.z - 1;
    if (rl.isKeyDown(.s)) move.z = move.z + 1;
    if (rl.isKeyDown(.a)) move.x = move.x - 1;
    if (rl.isKeyDown(.d)) move.x = move.x + 1;

    move = move.scale(0.2);

    camera.position = camera.position.add(move);
    camera.target = camera.target.add(move);
}
