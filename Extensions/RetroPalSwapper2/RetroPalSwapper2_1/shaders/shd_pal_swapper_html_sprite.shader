//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.	
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~//********SETUP*********
//The following variables must be populated specific to your project.
#define TexturePageSize 2048.
//Your texture page size.  Make sure it's actually exporting at the size you 
//set it if things seem funky.  
#define ColorCount 64.
//How tall is your color palette?  You could set this to the tallest one and
//leave it, but if you are experiencing performances issues, there are some
//ways to make this work a bit more efficiently.
#define PixelSize 1. / TexturePageSize
#define PalHeight ColorCount * PixelSize
#define Transparent vec4(.0, .0, .0, .0)
#define Tolerance 0.004

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_palTexture;
uniform vec4 u_Uvs;
uniform float u_paletteId;
uniform vec2 u_pixelSize;

vec4 findAltColor(vec4 inCol, vec2 corner)
{
  if (inCol.a == 0.) return Transparent;

  float dist;
  vec2 testPos;
  vec4 leftCol;
  for (float i = 0.; i < PalHeight; i += PixelSize)
  {
    testPos = vec2(corner.x, corner.y + i);
    leftCol = texture2D(u_palTexture, testPos);
    dist = distance(leftCol, inCol);
    if (dist <= Tolerance)
    {
      testPos = vec2(corner.x += u_pixelSize.x * u_paletteId, corner.y + i);
      return texture2D(u_palTexture, testPos);
    }
  }
  return inCol;
}

void main()
{
  vec4 col = texture2D(gm_BaseTexture, v_vTexcoord);
  col = findAltColor(col, u_Uvs.xy);
  gl_FragColor = v_vColour * col;
}
