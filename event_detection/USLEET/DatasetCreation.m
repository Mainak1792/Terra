clc, clear all, close all;
%%

% persons = {'Aditi' , 'Bodhi', 'Chand', 'Manohar' , 'Meenakshi', 'Prateek' , 'Nikhil' , 'Sahil', 'Shivaji' , 'Ved' };

% persons = {'Aditi' , 'Bodhi', 'Manohar' , 'Meenakshi', 'Priyanshu' , 'Sahil', 'Shivaji' , 'Ved' };

%persons = {'Aditi', 'Animesh', 'Aradhana' , 'Bodhi', 'Chand', 'Dayanand', 'Debanjan', 'Gundeep', 'Jasleen', 'Kanupriya','Mainak', 'Manohar', 'Meenakshi', 'Mudra', 'NaveenCh', 'Nikhil', 'Oshin', 'Pawan' ,'Prateek', 'Prerna' ,'Puja' ,'Rahul','Rajat', 'Rashmi', 'Richa', 'Sahil', 'Sangeeta', 'Sanhita', 'Shivaji', 'Shivani', 'Swarnima', 'Tehereem', 'Vaibhav','Ved', 'Vijoyatry', 'Vikas'};
% persons = {'Abhilash', 'Abhishek', 'Adnan' , 'Aman', 'Animesh','Aradhana' , 'Dayanand', 'Debanjan', 'Gundeep', 'Jasleen', 'Kanupriya','Mainak', 'Monica', 'Mudra', 'NaveenCh', 'Oshin', 'Pawan', 'Pradyot' ,'Prerna', 'Rahul', 'Rashmi', 'Richa', 'Sangeeta', 'Sanhita', 'Shivani', 'Sid', 'Survi' ,'Swarnima', 'Tehereem', 'Vaibhav', 'Vijoyatry', 'Vikas'};
% persons = {'Abhilash', 'Abhishek','Aditi','Adnan' , 'Aman', 'Animesh', 'Aradhana' , 'Bodhi', 'Chand', 'Dayanand', 'Debanjan', 'Gundeep', 'Jasleen', 'Kanupriya','Mainak', 'Manoj', 'Meenakshi', 'Monica' ,'Mudra', 'NaveenCh', 'Oshin', 'Pawan', 'Pradyot' ,'Prateek', 'Prerna', 'Priyanshu' , 'Rahul', 'Rashmi', 'Richa', 'Sagar', 'Sahil', 'Sangeeta', 'Sanhita', 'Shivaji', 'Shivani', 'Sid', 'Survi','Swarnima', 'Tehereem', 'Vaibhav','Ved', 'Venky', 'Vijoyatry', 'Vikas'};
persons = {'Aashi'}

mtr = 1.5;

dataset_original =[];
for j = 1:length(persons)
    
    data = [];
for i = 1:4
   
    filename = sprintf('%s_Wooden_%i.mat', persons{j}, i)
    load(filename)
    
    tempdata = geo_data;
    data = [data ; tempdata];
    
end

dataset_original = [dataset_original , data];

geo_data = data;
dataname = sprintf('%s_Cement',persons{j})
save(dataname, 'geo_data')

end

%%

% for j = 1:length(persons)
%    
%     filename = sprintf('D:\Python\WoodenLab\%s_Cement_4o5mtr.mat', persons{j})
%     load(filename)
%     
%    
%     
% end