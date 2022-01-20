float sqrtFast(float x) {
    return (2.0-x)*x;
}

vec3 sqrtFast(vec3 x) {
    return vec3(sqrtFast(x.r), sqrtFast(x.g), sqrtFast(x.b));
}

float getLum(vec3 x) {
    return sqrtFast(0.299 * x.r * x.r + 0.587 * x.g * x.g + 0.144 * x.b * x.b);
}