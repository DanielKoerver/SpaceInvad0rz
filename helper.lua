function distance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2)) 
end

function circlesCollide(x1, y1, r1, x2, y2, r2)
    return distance(x1, y1, x2, y2) <= r1 + r2
end