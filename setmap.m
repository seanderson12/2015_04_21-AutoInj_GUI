    function setmap(hObj,event) 
        % Called when user activates popup menu 
        val = get(hObj,'Value');
        if val ==1
            colormap(gray)
        elseif val == 2
            colormap(hsv)
        elseif val == 3
            colormap(jet)
        elseif val == 4
            colormap(hot)
        elseif val == 5
            colormap(cool)
        end
    end