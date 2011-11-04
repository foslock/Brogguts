//
//  QuadTree.c
//  OpenGLEngine
//
//  Created by James Lockwood on 8/3/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#include <stdlib.h>
#include <memory.h>
#include "QuadTree.h"

#define OBJECTS_ARRAY_INCREMENT_AMOUNT 4 // Can't be zero

struct _QuadTree {
    int totalWidth;
    int totalHeight;
    int maxDepth;
    TreeNode* treeRoot;
};

struct _TreeNode {
    int hasMadeChildrenNodes;
    TreeNode* childrenNodes[4];
    int objectCapacity;
    int objectCount;
    int nodeDepth;
    QuadRect nodeRect;
    NodeObject** objects;
};


//  This is how the nodes' children are set up
//  _________
//  | 0 | 1 |
//  |___|___|
//  | 2 | 3 |
//  |___|___|
//

enum QuadRectQuadrants {
    QuadRectQuadrantUpperLeft = 0,
    QuadRectQuadrantUpperRight = 1,
    QuadRectQuadrantLowerLeft = 2,
    QuadRectQuadrantLowerRight = 3,    
};

QuadRect QuadRectGetSubQuadrant(QuadRect originalRect, enum QuadRectQuadrants quadrant);
enum QuadRectQuadrants QuadrantForPointInRect(QuadRect rect1, int x, int y);
int QuadRectIntersectsRect(QuadRect rect1, QuadRect rect2);
int QuadRectContainsPoints(QuadRect rect1, int x, int y);
int QuadRectFullyContainsCircle(QuadRect rect1, int x, int y, int radius);

TreeNode* QuadTreeCreateTreeNode();
void QuadTreeDeleteNode(TreeNode* root);

void insertHelper(QuadTree* tree, TreeNode* node, int maxDepth, NodeObject* obj);
void addObjectToTreeNode(TreeNode* node, NodeObject* obj);
void checkAndExpandNodeObjects(TreeNode* node);

// Convienence functions
QuadRect QuadRectMake(int origin_x, int origin_y, int width, int height) {
    QuadRect rect;
    rect.x0 = origin_x;
    rect.y0 = origin_y;
    rect.x1 = origin_x + width;
    rect.y1 = origin_y + height;
    return rect;
}

QuadRect QuadRectFromNode(TreeNode* node) {
    return node->nodeRect;
}

QuadRect QuadRectGetSubQuadrant(QuadRect originalRect, enum QuadRectQuadrants quadrant) {
    QuadRect newRect;
    int width = (originalRect.x1 - originalRect.x0) / 2;
    int height = (originalRect.y1 - originalRect.y0) / 2;
    
    switch (quadrant) {
        case QuadRectQuadrantUpperLeft:
            newRect = QuadRectMake(originalRect.x0,
                                   originalRect.y0,
                                   width, height);
            break;
        case QuadRectQuadrantUpperRight:
            newRect = QuadRectMake((originalRect.x1 + originalRect.x0) / 2,
                                   originalRect.y0,
                                   width, height);
            break;
        case QuadRectQuadrantLowerLeft:
            newRect = QuadRectMake(originalRect.x0,
                                   (originalRect.y1 + originalRect.y0) / 2,
                                   width, height);
            break;
        case QuadRectQuadrantLowerRight:
            newRect = QuadRectMake((originalRect.x1 + originalRect.x0) / 2,
                                   (originalRect.y1 + originalRect.y0) / 2,
                                   width, height);
            break;
            
        default:
            break;
    }
    return newRect;
}

enum QuadRectQuadrants QuadrantForPointInRect(QuadRect rect1, int x, int y) {
    for (int i = 0; i < 4; i++) {
        QuadRect rect = QuadRectGetSubQuadrant(rect1, i);
        if (QuadRectContainsPoints(rect, x, y)) {
            return i;
        }
    }
    return 0;
}

int QuadRectIntersectsRect(QuadRect rect1, QuadRect rect2) {
    int returnBool = 1;
    if (rect1.x1 < rect2.x0 || rect1.x0 > rect2.x1) {
        returnBool = 0;
        return returnBool;
    }
    if (rect1.y1 < rect2.y0 || rect1.y0 > rect2.y1) {
        returnBool = 0;
        return returnBool;
    }
    return returnBool;
}

int QuadRectContainsPoints(QuadRect rect1, int x, int y) {
    int returnBool = 1;
    if (x <= rect1.x0 || x >= rect1.x1) {
        returnBool = 0;
        return returnBool;
    }
    if (y <= rect1.y0 || y >= rect1.y1) {
        returnBool = 0;
        return returnBool;
    }
    return returnBool;
}

int QuadRectFullyContainsCircle(QuadRect rect1, int x, int y, int radius) {
    int returnBool = 0;
    QuadRect newRect;
    newRect.x0 = rect1.x0 + radius;
    newRect.x1 = rect1.x1 - radius;
    newRect.y0 = rect1.y0 + radius;
    newRect.y1 = rect1.y1 - radius;
    if (QuadRectContainsPoints(newRect, x, y)) {
        returnBool = 1;
    }
    return returnBool;
}

// Returns a newly made DEFAULT tree node
TreeNode* QuadTreeCreateTreeNode() {
    TreeNode* newNode = (TreeNode*)malloc( sizeof(*newNode) );
    NodeObject** newObjs = (NodeObject**)malloc( OBJECTS_ARRAY_INCREMENT_AMOUNT * sizeof(*newObjs) );
    for (int i = 0; i < 4; i++) {
        newNode->childrenNodes[i] = NULL;
    }
    newNode->hasMadeChildrenNodes = 0;
    newNode->objectCount = 0;
    newNode->objectCapacity = OBJECTS_ARRAY_INCREMENT_AMOUNT;
    newNode->objects = newObjs;
    newNode->nodeDepth = 0;
    newNode->nodeRect = QuadRectMake(0, 0, 0, 0);
    return newNode;
}

// Recursively deletes all children of given node, and itself
void QuadTreeDeleteNodes(TreeNode* root) {
    if (root == NULL) {
        return;
    }
    for (int i = 0; i < 4; i++) {
        QuadTreeDeleteNodes(root->childrenNodes[i]);
        root->childrenNodes[i] = NULL;
    }
    for (int i = 0; i < root->objectCount; i++) {
        free(root->objects[i]);
    }
    free(root->objects);
    free(root);
}

void addObjectToTreeNode(TreeNode* node, NodeObject* obj) {
    checkAndExpandNodeObjects(node);
    node->objects[node->objectCount++] = obj;
    obj->parent = node;
}

void checkAndExpandNodeObjects(TreeNode* node) {
    if (node == NULL) {
        return;
    }
    if (node->objectCount == node->objectCapacity) {
        int tempCap = node->objectCapacity;
        NodeObject** objs = node->objects;
        NodeObject** newMemory = (NodeObject**)malloc( (tempCap + OBJECTS_ARRAY_INCREMENT_AMOUNT) * sizeof(*newMemory));
        node->objects = memcpy(newMemory, objs, node->objectCount * sizeof(*newMemory));
        node->objectCapacity = tempCap + OBJECTS_ARRAY_INCREMENT_AMOUNT;
        free(objs);
    }
}

// Nodes should be created with default slots for objects (objectCapacity > objectCount)
QuadTree* QuadTreeCreate(int width, int height, int maxDepth) {
    QuadTree* newTree = (QuadTree*)malloc( sizeof(*newTree) );
    newTree->maxDepth = maxDepth;
    newTree->totalWidth = width;
    newTree->totalHeight = height;
    newTree->treeRoot = QuadTreeCreateTreeNode();
    newTree->treeRoot->nodeRect = QuadRectMake(0, 0, width, height);
    return newTree;
}

void QuadTreeDestroy(QuadTree* tree) {
    if (tree) {
        QuadTreeDeleteNodes(tree->treeRoot);
        free(tree);
    }
}

NodeObject* QuadTreeCreateNode() {
    NodeObject* newNode = (NodeObject*)malloc( sizeof(*newNode) );
    newNode->parent = NULL;
    newNode->xPos = 0;
    newNode->yPos = 0;
    newNode->objectRadius = 0;
    newNode->effectRadius = 0;
    newNode->arrayIndex = -1;
    newNode->objectID = -1;
    return newNode;
}

void insertHelper(QuadTree* tree, TreeNode* node, int maxDepth, NodeObject* obj) {
    if (!node || !obj) {
        return;
    }
    if (node->nodeDepth == maxDepth) { // At the maximum layer of depth
        addObjectToTreeNode(node, obj);
        return;
    } else if (node->nodeDepth < maxDepth) { // Any layer before max
        if (node->objectCount == 0) { // If node has no objects, just add it
            addObjectToTreeNode(node, obj);
            return;
        } else { // If there are already objects in that node, make the children and rearrange all current objects
            if (!node->hasMadeChildrenNodes) { // Make the children nodes if they don't already exist
                for (int i = 0; i < 4; i++) {
                    node->childrenNodes[i] = QuadTreeCreateTreeNode();
                    node->childrenNodes[i]->nodeDepth = node->nodeDepth + 1;
                    node->childrenNodes[i]->nodeRect = QuadRectGetSubQuadrant(node->nodeRect, i);
                }
                node->hasMadeChildrenNodes = 1;
            }
            // Add the object to the node since we're going rearrange them all anyways
            addObjectToTreeNode(node, obj);
            
            // Go through each object stored and either add it to a child node, or keep it in current node
            int currentCount = node->objectCount;
            int* destinationArray = (int*)malloc(currentCount * sizeof(*destinationArray));
            NodeObject** tempObjsArray = (NodeObject**)malloc(currentCount * sizeof(*tempObjsArray));
            
            for (int i = 0; i < currentCount; i++) {
                NodeObject* thisObj = node->objects[i];
                tempObjsArray[i] = thisObj;
                int quadrant = QuadrantForPointInRect(node->nodeRect, thisObj->xPos, thisObj->yPos);
                if (QuadRectFullyContainsCircle(node->childrenNodes[quadrant]->nodeRect, thisObj->xPos, thisObj->yPos, thisObj->objectRadius)) {
                    // If a child fully contains it, remove it from the current node, and insert it into that child
                    destinationArray[i] = quadrant;
                } else {
                    // Else keep it in the current array of the current node (do nothing)
                    destinationArray[i] = -1;
                }
            }
            
            // Clear all current objects in the node
            node->objectCount = 0;
            
            for (int i = 0; i < currentCount; i++) {
                NodeObject* thisObj = tempObjsArray[i];
                if (destinationArray[i] == -1) {
                    // The object stays in this node and is not removed/moved
                    addObjectToTreeNode(node, thisObj);
                } else {
                    int quadrant = destinationArray[i];
                    insertHelper(tree, node->childrenNodes[quadrant], maxDepth, thisObj);
                }
            }
            free(destinationArray);
            free(tempObjsArray);
        }
    }
}

void QuadTreeInsertObject(QuadTree* tree, NodeObject* obj) {
    // Do stuff finding the right node
    if (tree && obj) {
        insertHelper(tree, tree->treeRoot, tree->maxDepth, obj);
    }
}

void QuadTreeDeleteObject(QuadTree* tree, NodeObject* obj) {
    if (obj) {
        QuadTreeRemoveObject(tree, obj);
        free(obj);
    }
}

void QuadTreeRemoveObject(QuadTree* tree, NodeObject* obj) {
    if (obj) {
        TreeNode* parent = obj->parent;
        if (parent) {
            if (parent->objectCount > 1) {
                // Replace the old one with the last in the array
                NodeObject* lastObj = parent->objects[parent->objectCount - 1];
                for (int i = 0; i < parent->objectCount; i++) {
                    if (parent->objects[i] == obj) {
                        parent->objects[i] = lastObj;
                        break;
                    }
                }
            } else if (parent->objectCount == 1) { // obj is only object in parent
                parent->objects[0] = NULL;
            }
            parent->objectCount--;
            obj->parent = NULL;
        }
    }
}

void QuadTreeUpdateObject(QuadTree* tree, NodeObject* obj) {
    // Update the tree with the objects new position/data
    
    // CHEAP METHOD
    QuadTreeRemoveObject(tree, obj);
    QuadTreeInsertObject(tree, obj);
    
    // Probably a faster way to do that...
    
}

// Recursively adds all of the objs contained within the "rect" (returns the count of objects)
// FIX THIS FUNCTION
int addObjectsOfNodeToArray(TreeNode* node, NodeObject** objs, int* currentCount, int maxCount, QuadRect rect) {
    if (QuadRectIntersectsRect(node->nodeRect, rect)) { // If outside rect intersects node rect, do stuff, else none added
        if ( (*currentCount) < maxCount) { // If the current count is less than the max, do stuff, else none added
            int thisNodeCount = 0; // Count for this node and all its children
            for (int i = 0; i < node->objectCount; i++) {
                objs[(*currentCount)++] = node->objects[i];
                thisNodeCount++;
                if ( (*currentCount) == maxCount) { // Return if reached max 
                    return thisNodeCount;
                }
            }
            if (node->hasMadeChildrenNodes) { // All that was added were on this node
                for (int i = 0; i < 4; i++) {
                    thisNodeCount += addObjectsOfNodeToArray(node->childrenNodes[i],
                                                             objs,
                                                             currentCount,
                                                             maxCount,
                                                             rect);
                }
            }
            return thisNodeCount;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

int QuadTreeQuery(QuadTree* tree, NodeObject** objs, unsigned int max, QuadRect rect) {
    int countAdded = 0;
    if (objs) {
        addObjectsOfNodeToArray(tree->treeRoot, objs, &countAdded, max, rect);
    }
    return countAdded;
}

