---
id:        "20240930-rotation-matrix"
title:     "Deriving the 2D Rotation Matrix"
author:    "Jonathan Merritt"
tags:      ["graphics", "2d", "rotation"]
published: 2024-09-30
updated:   2024-09-30
---

The Wikipedia article on 
[rotation matrices](https://en.wikipedia.org/wiki/Rotation_matrix)
is pretty good, but it doesn't cover a derivation of rotation matrices.

A simple way to derive a 2D rotation matrix is to use complex exponential
functions:

<displaymath id="eq:complex-pt">
x = re^{i\theta}
</displaymath>
