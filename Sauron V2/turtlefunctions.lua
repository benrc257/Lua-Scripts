local function triangulate() -- returns GPS coordinates
    repeat
        x, y, z = gps.locate(5);
    until (x ~= nil);
    return x, y, z;
end

return {
    triangulate = triangulate
}