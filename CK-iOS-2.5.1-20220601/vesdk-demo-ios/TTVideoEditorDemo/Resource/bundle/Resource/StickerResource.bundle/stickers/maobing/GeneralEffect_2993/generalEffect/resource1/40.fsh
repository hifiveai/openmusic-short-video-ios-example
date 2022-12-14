
varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform lowp float gamma;

void main() {
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    gl_FragColor = vec4(pow(textureColor.rgb, vec3(gamma)), textureColor.w);
}
