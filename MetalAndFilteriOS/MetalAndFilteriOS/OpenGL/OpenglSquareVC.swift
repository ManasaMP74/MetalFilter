//
//  OpenglSquareVC.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 14/03/23.
//

import UIKit

// https://www.kodeco.com/9211-moving-from-opengl-to-metal#toc-anchor-002

class OpenglSquareVC: GLKViewController {
    struct Vertex {
      /// Stores the X coordinate of a vertex.
      var x: GLfloat
      /// Stores the Y coordinate of a vertex.
      var y: GLfloat
      /// Stores the Z coordinate of a vertex.
      var z: GLfloat
      /// Stores the red color value of a vertex.
      var r: GLfloat
      /// Stores the green color value of a vertex.
      var g: GLfloat
      /// Stores the blue color value of a vertex.
      var b: GLfloat
      /// Stores the alpha value of a vertex.
      var a: GLfloat
    }
    var Vertices = [
      Vertex(x:  1, y: -1, z: 0, r: 1, g: 0, b: 0, a: 1),
      Vertex(x:  1, y:  1, z: 0, r: 0, g: 1, b: 0, a: 1),
      Vertex(x: -1, y:  1, z: 0, r: 0, g: 0, b: 1, a: 1),
      Vertex(x: -1, y: -1, z: 0, r: 0, g: 0, b: 0, a: 1),
      ]
    
    var Indices: [GLubyte] = [0, 1, 2, 2, 3, 0]
    
    private var context: EAGLContext?
    private var effect = GLKBaseEffect()
    private var rotation: Float = 0.0
    private var ebo = GLuint()
    private var vbo = GLuint()
    private var vao = GLuint()
    
    deinit {
      tearDownGL()
    }
    
    private func setupGL() {
      context = EAGLContext(api: .openGLES3)
      EAGLContext.setCurrent(context)
      
      if let view = view as? GLKView, let context = context {
        view.context = context
        delegate = self
      }
      
      // Helper variables to identify the position and color attributes for OpenGL calls.
      let vertexAttribColor = GLuint(GLKVertexAttrib.color.rawValue)
      let vertexAttribPosition = GLuint(GLKVertexAttrib.position.rawValue)
      
      // The size, in memory, of a Vertex structure.
      let vertexSize = MemoryLayout<Vertex>.stride
      let colorOffset = MemoryLayout<GLfloat>.stride * 3
      let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
      
      // VAO
      
      // Generate and bind a vertex array object.
      glGenVertexArraysOES(1, &vao)
      glBindVertexArrayOES(vao)
      
      // VBO
      glGenBuffers(1, &vbo)
      glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
      glBufferData(GLenum(GL_ARRAY_BUFFER), Vertices.size(), Vertices, GLenum(GL_STATIC_DRAW))
      glEnableVertexAttribArray(vertexAttribPosition)
      glVertexAttribPointer(vertexAttribPosition, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), nil)
      
      // Enable the colors vertex attribute to then specify information about how the color of a vertex is stored.
      glEnableVertexAttribArray(vertexAttribColor)
      glVertexAttribPointer(vertexAttribColor, 4, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), colorOffsetPointer)
      
      // EBO
      glGenBuffers(1, &ebo)
      glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
      glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), Indices.size(), Indices, GLenum(GL_STATIC_DRAW))
      glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
      glBindVertexArrayOES(0)
    }
    
    /// Perform cleanup, and delete buffers and memory.
    private func tearDownGL() {
      EAGLContext.setCurrent(context)
      
      glDeleteBuffers(1, &vao)
      glDeleteBuffers(1, &vbo)
      glDeleteBuffers(1, &ebo)
      
      EAGLContext.setCurrent(nil)
      context = nil
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      setupGL()
    }
  }

extension OpenglSquareVC: GLKViewControllerDelegate {
  func glkViewControllerUpdate(_ controller: GLKViewController) {
    let aspect = fabsf(Float(view.bounds.size.width) / Float(view.bounds.size.height))
    let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 4.0, 10.0)
    effect.transform.projectionMatrix = projectionMatrix
    
    var modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0)
    rotation += 90 * Float(timeSinceLastUpdate)
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(rotation), 0, 0, 1)
    effect.transform.modelviewMatrix = modelViewMatrix
  }

  override func glkView(_ view: GLKView, drawIn rect: CGRect) {
    glClearColor(0.85, 0.85, 0.85, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    
    effect.prepareToDraw()
    glBindVertexArrayOES(vao)
    glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
    glBindVertexArrayOES(0)
  }
}

extension Array {
  func size() -> Int {
    return count * MemoryLayout.size(ofValue: self[0])
  }
}
