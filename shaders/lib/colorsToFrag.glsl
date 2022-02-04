vec4 rgbaWrite(vec4 tex, vec3 fColor, float cover) {
    float alpha;
    vec3 resCol;
    if (cover < 1.0) {
        resCol = mix(tex.rgb, fColAdj(fColor), cover);
        if (tex.a != round(tex.a)) {
            alpha = mix(tex.a, 1.0, cover);
        } else {
            alpha = tex.a;
        }
    } else { // Completely covered with fog;
        resCol = fColAdj(fColor);
        alpha = 1.0;
    }
    return vec4(resCol, alpha);
}