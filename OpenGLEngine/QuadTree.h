//
//  QuadTree.h
//  OpenGLEngine
//
//  Created by James Lockwood on 8/3/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif
    
#ifndef OpenGLEngine_QuadTree_h
#define OpenGLEngine_QuadTree_h
    
    typedef struct _QuadTree QuadTree;
    typedef struct _TreeNode TreeNode;
    
    typedef struct _NodeObject {
        TreeNode* parent;
        int arrayIndex;
        int objectID;
        int objectRadius;
        int effectRadius;
        int xPos;
        int yPos;
    } NodeObject;
    
    typedef struct _QuadRect {
        int x0, x1, y0, y1;
    } QuadRect;
    
    QuadRect QuadRectMake(int origin_x, int origin_y, int width, int height);
    QuadRect QuadRectFromNode(TreeNode* node);
    
    // Width and Height MUST be powers of two for the tree to work correctly
    QuadTree* QuadTreeCreate(int width, int height, int maxDepth);
    NodeObject* QuadTreeCreateNode();
    
    void QuadTreeInsertObject(QuadTree* tree, NodeObject* obj);
    void QuadTreeDeleteObject(QuadTree* tree, NodeObject* obj); // Delete takes care of memory
    void QuadTreeRemoveObject(QuadTree* tree, NodeObject* obj);
    void QuadTreeUpdateObject(QuadTree* tree, NodeObject* obj);
    
    // Puts at max "max" objects in "objs" that are contained with "rect" (in the structure "tree")
    int QuadTreeQuery(QuadTree* tree, NodeObject** objs, unsigned int max, QuadRect rect);
    
    void QuadTreeDestroy(QuadTree* tree);
    
#endif
    
#ifdef __cplusplus
}
#endif