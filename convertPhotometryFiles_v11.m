%myDir = input("Please enter the directory where the Green Channel and Isobestic .csv files are located: ", 's');
%mySC = input("Please enter the number of the column of your SIGNAL ROI: ", 's'); 

mySC = '5'; %stands for my Signal Column - since this will not regularly change, we will keep it hard-coded here

%However, this will enable this script to be adapted in the future when
%using multiple ROIs in a branched cable, for example

mySC = str2num(mySC);

myDir = 'C:\Users\fieldslab1\Desktop\fibphot_6_5_23_mgm'
% Above is where you input the directory containing your files
myOtherDir = dir(fullfile(myDir, '**\*.csv'));
behaviorDir = myOtherDir;

tf = contains( {myOtherDir.name}, {'Beh', 'Int', 'Average', 'AUC', 'Plot', 'Trial', 'Trace', 'shock', 'KeyPress', 'ROI', 'testing', 'regions', 'pMat', 'READY'});
cf = contains( {myOtherDir.name}, {'shockTimes'}); 
% This is where I have been basically filtering the files that come up in
% the search. I now realize I probably could have just done it in the
% forward direction instead of reverse, but this works fine. If there are
% any other new files introduced to the filesystem and they interfere,
% they can be added in here.

myOtherDir(tf) = [];
behaviorDir(~cf) = [];

titles = ["Timestamp" "Signal, (Column from Bonsai output): "+mySC "Isobestic Control (GCaMP isosbestic excited by 405 LED))"];
titlesRed = ["Timestamp" "Signal, (Column from Bonsai output): "+mySC "Red Control (tdTomato excited by 470 LED): "];
% These are the column titles for the output .csv files for pmat, just for
% ease of use.


[~,idx] = sort([myOtherDir.datenum]);
myOtherDir = myOtherDir(idx)

for i=1:2:(length(myOtherDir))  

    clear newArr
    clear newArr2

    file = myOtherDir(i,1).name;
    folder = myOtherDir(i,1).folder;
    actual = strcat(folder,'\',file);
    data = csvread(actual, 1);

    newArr(:, 1) = data(:,2);
    newArr2(:, 1) = data(:,2);

    saveCol = data(:, mySC-1); 

    newArr(:,2) = data(:,mySC);
    newArr2(:,2) = data(:,mySC);
    
   
    file = myOtherDir(i+1,1).name;
    folder = myOtherDir(i+1,1).folder;
    actual = strcat(folder,'\',file);
    data = csvread(actual, 1);

    if length(data) < length(newArr)
        newArr(end-1,:) = [];
        newArr2(end-1,:) = [];
    end
    while length(data) > length(newArr)
        data(end-1,:) = [];
    end
    if length(saveCol) < length(newArr)
        saveCol(end-1,:) = [];
    end
    while length(saveCol) > length(newArr2)
        saveCol(end-1,:) = [];
    end
% The above set of loops is here to deal with the fact that sometimes one
% or the other file has one or more extra columns. this checks for that and
% deletes the extras.

newArr2(:,3) = saveCol;
%Since I am looping through, but want to keep the same timestamps from the
%first file, I save it to a variable here

newArr(:,3) = data(:,mySC);

names = {myOtherDir.name};
char(names);

T = array2table(newArr, "VariableNames", titles);
writetable(T, (names(i) + "-pMatReady-Isobestic.csv"))

T2 = array2table(newArr2, "VariableNames", titlesRed);
writetable(T2, (names(i) + "-pMatReady-RedControl.csv"))

end

newCol = 'shock';

for i=1:(length(behaviorDir))
    clear myTable
    clear count
    file = behaviorDir(i,1).name;
    folder = behaviorDir(i,1).folder;
    actual = strcat(folder,'\',file);
    myTable = readtable(actual, "Range", 1);
    myTable(:, 1) = [];
    myTable(19,:) = [];
    myTable=rmmissing(myTable)
    count = height(myTable)
    myTable.Event = repmat(newCol, count, 1)
    names2 = {behaviorDir.name}

    myTable = myTable(:, [3 1 2])

    writetable(myTable, (names2(i)+ "-READY.csv"))
end

