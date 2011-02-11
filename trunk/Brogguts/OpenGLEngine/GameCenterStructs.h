
// Things used in GC classes

enum RemoteEntityTypes {
	kRemoteEntityLocal, // Object data is not transferred
	kRemoteEntitySimple, // Just ID, X and Y values are transferred
	kRemoteEntityRotating, // Just ID, X, Y, and rotation values are transferred
	kRemoteEntityComplex, // ID, X, Y, rotation, velocity, and other data is transferred
};

enum PacketTypes {
	kPacketTypeSimpleEntity, // Just X and Y values
	kPacketTypeRotatingEntity, 
	kPacketTypeComplexEntity, // Position vector, velocity vector, rotation, rotation speed
};

typedef struct Simple_Entity {
	int packetType;
	int objectID;
	float x;
	float y;
} SimpleEntityPacket;

typedef struct Rotating_Entity {
	int packetType;
	int objectID;
	float x;
	float y;
	float rotation;
} RotatingEntityPacket;

typedef struct Complex_Entity {
	int packetType;
	int objectID;
	Vector2f position;
	Vector2f velocity;
	float rotation;
	float rotationSpeed; // CCW is positive
						 // AND MORE...
} ComplexEntityPacket;
