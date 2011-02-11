//
//  Shader.vsh
//  OpenGLEngine
//
//  Created by James F Lockwood on 1/25/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;

uniform float translate;

void main()
{
    gl_Position = position;
    gl_Position.y += sin(translate) / 2.0;

    colorVarying = color;
}
