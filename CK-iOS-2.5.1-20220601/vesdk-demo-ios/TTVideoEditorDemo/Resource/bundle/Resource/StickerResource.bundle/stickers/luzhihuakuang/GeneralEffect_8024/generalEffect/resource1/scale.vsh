precision highp float;

attribute vec3 attPosition;
attribute vec2 attUV;

varying vec2 textureCoordinate;

uniform float uScale;

void main() {
    vec2 position = attPosition.xy;
    position = position * uScale;
    gl_Position = vec4(position.xy, attPosition.z , 1.0);
    textureCoordinate = attUV.xy;
}
