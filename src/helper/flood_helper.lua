local points = require("src.model.points")

local flood_helper = {}

local result = {}

local function floodAgain(pointList, addPointsBool)

    local morePoints = {}

    for j=#pointList,1,-1 do

        local localPoint = pointList[j]

        if (result[localPoint.x-1][localPoint.y] ==  0) then
            result[localPoint.x-1][localPoint.y]=1
            if (addPointsBool) then
                table.add(morePoints, points.createPoint(localPoint.x-1, localPoint.y))
            end
        end

        if (result[localPoint.x+1][localPoint.y] ==  0) then
            result[localPoint.x+1][localPoint.y]=1
            if (addPointsBool) then
                table.add(morePoints, points.createPoint(localPoint.x+1, localPoint.y))
            end
        end

        if (result[localPoint.x][localPoint.y-1] ==  0) then
            result[localPoint.x][localPoint.y-1]=1
            if (addPointsBool) then
                table.add(morePoints, points.createPoint(localPoint.x, localPoint.y-1))
            end
        end

        if (result[localPoint.x][localPoint.y+1] ==  0) then
            result[localPoint.x][localPoint.y+1]=1
            if (addPointsBool) then
                table.add(morePoints, points.createPoint(localPoint.x, localPoint.y+1))
            end
        end

    end

    return morePoints

end

--[[
grid looks something like this : 

0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 
0 0 1 1 0 0 0 0 1 1 1 1 0 0 1 
0 0 1 1 0 0 0 0 1 0 1 1 0 0 1 
0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 
1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 
1 1 1 0 0 0 1 0 0 0 0 0 1 1 0 
0 1 0 1 0 1 1 0 0 0 0 0 1 1 0 
0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 

result on return should look something like this for point = 4, 4

0 0 1 1 1 0 0 0 0 0 0 0 0 0 0 
0 1 0 0 1 1 0 0 0 0 0 0 0 0 0 
1 1 0 0 1 1 1 0 0 0 0 0 0 0 0 
1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 
1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 
0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 
0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 
0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 

what we are getting now as the result:

0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 
0 0 1 1 0 0 0 0 1 1 1 1 0 0 1 
0 0 1 1 0 0 0 0 1 0 1 1 0 0 1 
0 0 1 0 1 0 0 0 0 0 0 0 0 1 0 
0 0 0 1 0 0 0 0 0 0 0 0 0 1 1 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 
1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 
1 1 1 0 0 0 1 0 0 0 0 0 1 1 0 
0 1 0 1 0 1 1 0 0 0 0 0 1 1 0 
0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 

]]
function flood_helper.getMovementGrid(grid, point, movementPoints)
    
    result = grid
    local pointsToConsider = {}
	table.insert(pointsToConsider, point)

    for i=movementPoints,1,-1 do
        local test = false
        if movementPoints>1 then
            test = true
        end

        local testPoints = floodAgain(pointsToConsider, test);
        pointsToConsider = testPoints;
    end

    return result
end

return flood_helper

