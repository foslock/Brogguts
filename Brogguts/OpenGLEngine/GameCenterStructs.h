
// Things used in GC classes

enum RemoteEntityTypes {
	kRemoteEntityLocal, // Object data is not transferred
	kRemoteEntitySimple, // Just ID, X and Y values are transferred
	kRemoteEntityRotating, // Just ID, X, Y, and rotation values are transferred
	kRemoteEntityComplex, // ID, X, Y, rotation, velocity, and other data is transferred
};

enum PacketTypes {
    kPacketTypeMatchPacket,
    kPacketTypeCreationPacket,
    kPacketTypeDestructionPacket,
    kPacketTypeBroggutUpdatePacket,
	kPacketTypeSimpleEntity, // Just X and Y values
	kPacketTypeRotatingEntity, 
	kPacketTypeComplexEntity, // Position vector, velocity vector, rotation, rotation speed
};

enum MatchMarkerTypes {
    kMatchMarkerRequestStart,
    kMatchMarkerConfirmStart,
};

typedef struct Match_Packet {
    int packetType;
    int matchMarker;
} MatchPacket;

typedef struct Creation_Packet {
    int packetType;
    int objectTypeID;
    int objectID;
    Vector2f position;
} CreationPacket;

typedef struct Destruction_Packet {
    int packetType;
    int objectID;
} DestructionPacket;

typedef struct Broggut_Packet {
    int packetType;
    CGPoint broggutLocation;
    int newValue;
} BroggutUpdatePacket;

typedef struct Simple_Entity {
	int packetType;
	int objectID;
	Vector2f position;
} SimpleEntityPacket;

typedef struct Rotating_Entity {
	int packetType;
	int objectID;
	Vector2f position;
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
