package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import openfl.Assets;

class Level extends Entity
{
    public static inline var TILE_SIZE = 10;

    public var walls(default, null):Grid;
    private var tiles:Tilemap;
    public var entities(default, null):Array<MiniEntity>;

    public function new(levelName:String) {
        super(0, 0);
        type = "walls";
        loadLevel(levelName);
        updateGraphic();
        mask = walls;
    }


    override public function update() {
        super.update();
    }

    private function loadLevel(levelName:String) {
        var levelData = haxe.Json.parse(Assets.getText('levels/${levelName}.json'));
        for(layerIndex in 0...levelData.layers.length) {
            var layer = levelData.layers[layerIndex];
            if(layer.name == "walls") {
                // Load solid geometry
                walls = new Grid(levelData.width, levelData.height, layer.gridCellWidth, layer.gridCellHeight);
                for(tileY in 0...layer.grid2D.length) {
                    for(tileX in 0...layer.grid2D[0].length) {
                        walls.setTile(tileX, tileY, layer.grid2D[tileY][tileX] == "1");
                    }
                }
                mask = walls;
            }
            else if(layer.name == "entities") {
                // Load entities
                entities = new Array<MiniEntity>();
                for(entityIndex in 0...layer.entities.length) {
                    var entity = layer.entities[entityIndex];
                    if(entity.name == "player") {
                        entities.push(new Player(entity.x - 6, entity.y - 8));
                    }
                    else if(entity.name == "checkpoint") {
                        entities.push(new Checkpoint(entity.x - 6, entity.y - 24));
                    }
                    else if(entity.name == "lock") {
                        entities.push(new Lock(entity.x, entity.y, entity.width, entity.height));
                    }
                    else if(entity.name == "bossTrigger") {
                        entities.push(new BossTrigger(
                            entity.x, entity.y, entity.width, entity.height,
                            entity.values.bossNames
                        ));
                    }
                    else if(entity.name == "testBoss") {
                        entities.push(new TestBoss(entity.x, entity.y));
                    }
                    else if(entity.name == "testBossTwo") {
                        entities.push(new TestBossTwo(entity.x, entity.y));
                    }
                    else if(entity.name == "testBossThree") {
                        entities.push(new TestBossThree(entity.x, entity.y, getPathNodes(entity, entity.nodes)));
                    }
                    else if(entity.name == "movingPlatform") {
                        entities.push(new MovingPlatform(
                            entity.x, entity.y,
                            entity.width, entity.height,
                            getPathNodes(entity, entity.nodes)
                        ));
                    }
                    else if(entity.name == "oneWayPlatform") {
                        entities.push(new OneWayPlatform(entity.x, entity.y, entity.width));
                    }
                    else if(entity.name == "spikeCeiling") {
                        entities.push(new Spike(entity.x, entity.y, Spike.CEILING, entity.width));
                    }
                    else if(entity.name == "spikeFloor") {
                        entities.push(new Spike(entity.x, entity.y, Spike.FLOOR, entity.width));
                    }
                    else if(entity.name == "spikeLeftWall") {
                        entities.push(new Spike(entity.x, entity.y, Spike.LEFT_WALL, entity.height));
                    }
                    else if(entity.name == "spikeRightWall") {
                        entities.push(new Spike(entity.x, entity.y, Spike.RIGHT_WALL, entity.height));
                    }
                    else if(entity.name == "tutorial") {
                        entities.push(new Tutorial(entity.x, entity.y, entity.values.text));
                    }
                }
            }
        }
    }

    private function getPathNodes(entity:Dynamic, nodes:Dynamic) {
        var pathNodes = new Array<Vector2>();
        pathNodes.push(new Vector2(entity.x, entity.y));
        for(i in 0...entity.nodes.length) {
            pathNodes.push(new Vector2(entity.nodes[i].x, entity.nodes[i].y));
        }
        pathNodes.push(new Vector2(entity.x, entity.y));
        return pathNodes;
    }

    public function updateGraphic() {
        tiles = new Tilemap(
            'graphics/tiles.png',
            walls.width, walls.height, walls.tileWidth, walls.tileHeight
        );
        for(tileX in 0...walls.columns) {
            for(tileY in 0...walls.rows) {
                if(walls.getTile(tileX, tileY)) {
                    tiles.setTile(tileX, tileY, 0);
                }
            }
        }
        graphic = tiles;
    }
}

