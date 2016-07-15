function [] = guiDemoCalculateScreenPosition();
%cm
screenDist = 92;
screenHalfWidth = 50;
ipd= 6
figH = figure(42);
clf
leCenter = [-ipd/2 0]; 
reCenter =  [ipd/2 0];
%draw a screen:
screenH= line([-screenHalfWidth;screenHalfWidth],[screenDist;screenDist],'color','k');
axH = gca;
hold on;
axis equal;
viscircles([leCenter;reCenter],[1.25; 1.25]);

%fixated at center of screen
leFixLineH = line(leCenter,[0 screenDist],'linestyle',':','color',[.4 .4 .4])
reFixLineH = line(reCenter,[0 screenDist],'linestyle',':','color',[.4 .4 .4])

%initial position for object
objPos = [0 screenDist]
objMarkerH = plot(objPos(1),objPos(2),'k+');
%leY = interp1([leCenter(1) objInitPos(1)],[leCenter(2) objInitPos(2)],screenDist,'linear','extrap')
leX = calcX(leCenter,objPos);
reX = calcX(reCenter,objPos);

leObjLineH = line(leCenter,[leX screenDist],'linestyle','-','color','b')
reObjLineH = line(reCenter,[reX screenDist],'linestyle','-','color','r')

fixation3 = [0 0 screenDist];
objPos3  = [objPos(1) 0 objPos(2)];
leCenter3 = [leCenter(1) 0 leCenter(2)];
reCenter3 = [reCenter(1) 0 reCenter(2)];
[screenL, screenR] = calculateScreenLocation(fixation3, objPos3, leCenter3, reCenter3);
leScreenMarkerH=plot(screenL(1),screenDist,'bx');
reScreenMarkerH=plot(screenR(1),screenDist,'rx');


legend([screenH leScreenMarkerH reScreenMarkerH objMarkerH leObjLineH reObjLineH],'screen',...
    'LE from calculateScreenLocation','RE from calculateScreenLocation',...
    'Object Position','LE line from eye through object','RE line from eye through object',...
    'Location','BestOutside')
xlabel('X (cm)');
ylabel('Z (cm)');
set(gca,'ButtonDownFcn',@clickedPlot)
set(leFixLineH,'ButtonDownFcn',@clickedPlot)
set(reFixLineH,'ButtonDownFcn',@clickedPlot)

    function clickedPlot(varargin)
        
        tCurPoint = get(axH,'CurrentPoint');
        
        objPos = tCurPoint(1,1:2);
        delete(objMarkerH);
        objMarkerH = plot(objPos(1),objPos(2),'k+');
        
        leX =  calcX(leCenter,objPos);
        xData = get(leObjLineH,'XData');
        xData(2) = leX;
        set(leObjLineH,'XData',xData);
        reX =  calcX(reCenter,objPos);
        xData = get(reObjLineH,'XData');
        xData(2) = reX;
        set(reObjLineH,'XData',xData);
        
        %Now use calculateScreenLocation
        fixation3 = [0 0 screenDist];
        objPos3  = [objPos(1) 0 objPos(2)];
        leCenter3 = [leCenter(1) 0 leCenter(2)];
        reCenter3 = [reCenter(1) 0 reCenter(2)];
        [screenL, screenR] = calculateScreenLocation(fixation3, objPos3, leCenter3, reCenter3);
        delete(leScreenMarkerH);
        delete(reScreenMarkerH);
        leScreenMarkerH=plot(screenL(1),screenDist,'bx');
        reScreenMarkerH=plot(screenR(1),screenDist,'rx');
        
    end

    function x=calcX(eye,obj)
        
        x = interp1([eye(2) obj(2)],[eye(1) obj(1)],screenDist,'linear','extrap');
    end

end