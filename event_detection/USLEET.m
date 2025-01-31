clc , close all,  clear ;
%%
% addpath(genpath('/home/sahil/Desktop/AcademicStuff/Dataset'))



% load('Sahil_Wooden.mat')
load("C:\Users\chand\Downloads\Data_Recording\P1_all.mat");
% load('Sahil_erricsson_4.mat')


% geo_data = dataset_original(:,1);
%%

Fs = 8000;
n = 100*Fs;

% geo_data = wdenoise(geo_data(1:n),5,'DenoisingMethod','BlockJS');
% geo_data = wdenoise(geo_data(1:n),9,'Wavelet','db1' );
geo_data = smooth(geo_data(1:n),5);
tm = (0:length(geo_data)-1)/Fs; 

%%
figure(1)
plot(tm,geo_data)
grid on
xlabel('Time (sec)')
ylabel('Aplitude(V)')



tau = 1.2;
window = 0.35; % 220ms is taken as the window size
wndw_ovrlap = 0.40;
wndw_smpl = window*Fs;

num_seg=floor(1+(length(geo_data)-wndw_smpl)/(floor((1-wndw_ovrlap)*wndw_smpl)));

figure(2)

for i = 1:num_seg
    
    start = floor(wndw_smpl*(i-1)*(1-wndw_ovrlap) + 1);
    stop = floor(start + wndw_smpl -1);
    if stop >= length(geo_data)
        stop = length(geo_data);
    end
    wght_wndw = length(start:stop);
    weight = gausswin(wght_wndw,tau);  % calculating gaussian weights 
%     weight = tukeywin(wght_wndw,0.5); % turkey window
%     weight = hamming(wght_wndw); % calculate blackman window weights 
   w_diag = diag(weight);
    sig = w_diag*geo_data(start:stop);
 
    
    ovrlp_sig = [zeros(start-1,1); geo_data(start:stop) ; zeros((length(geo_data)-stop),1)];
    
    signal_feat(i,:) = Events_Features_Extraction(Fs,sig);
   
end



signal_param = signal_feat;

%%
Cluster_num  = 2;

[clust, cov_mat, mu_mat, phi] = GMM_EM(signal_param, Cluster_num);

[Y] = tsne(signal_param,'Algorithm','exact','Standardize',0,'Distance','cosine'); % fro plottinng 3D 

%% Creating and Traing the SVM Model 

c1_idx = clust{1,1};
c2_idx = clust{1,2};
%c3_idx = clust{1,3};

figure(2)
plot(signal_param(c1_idx,1),signal_param(c1_idx,2),'ko','MarkerFaceColor','y','MarkerSize',7)
% plot(Y(c1_idx,1),Y(c1_idx,2),'ko','MarkerFaceColor','y','MarkerSize',7)
hold on
% plot(Y(c2_idx,1),Y(c2_idx,2),'ko','MarkerFaceColor','g','MarkerSize',7)
plot(signal_param(c2_idx,1),signal_param(c2_idx,2),'ko','MarkerFaceColor','g','MarkerSize',7)
%hold on
% plot(signal_param(c4_idx,3),signal_param(c4_idx,4),'ko','MarkerFaceColor','r','MarkerSize',7)
legend('Cluster 1', 'Cluster 2')
hold off
grid on
xlabel('x\_1')
ylabel('x\_2')
title('Actual Distribution of the Dataset')

fprintf('Press Enter To Continue \n');
pause()

train_data = [signal_feat(c1_idx,1:end) ; signal_feat(c2_idx,1:end)];

if det(cov_mat(:,:,1)) > det(cov_mat(:,:,2))
    train_label = [ones(length(c1_idx),1); zeros(length(c2_idx),1)];
    lbl_clst1 = 1;
    lbl_clst2 = 0;
else
    train_label = [zeros(length(c1_idx),1); ones(length(c2_idx),1)];
    lbl_clst1 = 0;
    lbl_clst2 = 1;
end

%% Testing on the blind dataset


% persons = {'Aashi', 'Aditi' , 'Anirudh', 'Anjan' , 'Anshuman' , 'Ayush', 'Bodhi' , 'Chandan' , 'Devendra' , 'Ekta' ,'Hitesh', 'KalaKanhu' , 'Kartik' , 'Krishan' , 'Manas_Sr' ,'Manas' ,'Manohar', 'Meenakshi' , 'Murli', 'Nimish' , 'Prateek', 'Priyanka' ,'Priyanshu' , 'Rahul' , 'Sahil', 'Sameer', 'Santosh', 'Satyam',  'Saubhadra' ,'Shilpi' ,'Shivaji', 'Shivam', 'Srijan', 'Suraj', 'Surbhi' ,'Varun', 'Wijitha' ,'Yamini'};
% persons = {'Abhilash', 'Abhishek','Aditi','Adnan' , 'Aman', 'Animesh', 'Aradhana' , 'Bodhi', 'Chand', 'Dayanand', 'Debanjan', 'Gundeep', 'Jasleen', 'Kanupriya','Mainak', 'Manoj', 'Meenakshi', 'Monica' ,'Mudra', 'NaveenCh', 'Oshin', 'Pawan', 'Pradyot' ,'Prateek', 'Prerna', 'Priyanshu' , 'Rahul', 'Rashmi', 'Richa', 'Sagar', 'Sahil', 'Sangeeta', 'Sanhita', 'Shivaji', 'Shivani', 'Sid', 'Survi','Swarnima', 'Tehereem', 'Vaibhav','Ved', 'Venky', 'Vijoyatry', 'Vikas'};
% persons = {'Abhilash', 'Abhishek','Aditi','Adnan' , 'Aman', 'Animesh', 'Aradhana' , 'Bodhi', 'Chand', 'Dayanand', 'Debanjan', 'Gundeep', 'Jasleen', 'Kanupriya','Mainak', 'Manoj', 'Meenakshi', 'Monica' ,'Mudra', 'NaveenCh', 'Oshin', 'Pawan', 'Pradyot' ,'Prateek', 'Prerna', 'Priyanshu' , 'Rahul', 'Rashmi', 'Richa', 'Sagar', 'Sahil', 'Sangeeta', 'Sanhita', 'Shivaji', 'Shivani', 'Sid', 'Survi','Swarnima', 'Tehereem', 'Vaibhav','Ved', 'Venky', 'Vijoyatry', 'Vikas'};
%persons = {'Aditi', 'Animesh', 'Aradhana' , 'Bodhi', 'Chand', 'Dayanand', 'Debanjan', 'Gundeep', 'Jasleen', 'Kanupriya','Mainak', 'Manohar', 'Meenakshi', 'Mudra', 'NaveenCh', 'Nikhil', 'Oshin', 'Pawan' ,'Prateek', 'Prerna' ,'Puja' ,'Rahul','Rajat', 'Rashmi', 'Richa', 'Sahil', 'Sangeeta', 'Sanhita', 'Shivaji', 'Shivani', 'Swarnima', 'Tehereem', 'Vaibhav','Ved', 'Vijoyatry', 'Vikas'};
%persons = {'Antarikhs','Apoorv','Atharv','Komal','Neha','Om','Pallavjnu','Rishi','Rishika','Rutuja','Shivamj','Sibashish','Tenin','Utkarsh','Vijay','NAntarikhs','NApoorv','NAtharv','NKomal','NNeha','NOm','NPallavjnu','NRishi','NRishika','NRutuja','NShivamj','NSibashish','NTenin','NUtkarsh','NVijay','SAntarikhs','SApoorv','SAtharv','SKomal','SNeha','SOm','SPallavjnu','SRishi','SRishika','SRutuja','SShivamj','SSibashish','STenin','SUtkarsh','SVijay'}
%persons =  {'SAntarikhs','SApoorv','SAtharv','SKomal','SNeha','SOm','SPallavjnu','SRishi','SRishika','SRutuja','SShivamj','SSibashish','STenin','SUtkarsh','SVijay'}
%persons = {'Aayushi', 'Aiswarya', 'Akash', 'Alice','Aman','Ameen','Amitstaff', 'Anagh', 'Anil', 'AnkitK', 'Antarikhs', 'Aritra_Mtech', 'Arnav', 'Arunp','Aryan','Ashiq','Asmit','Asmita','Atharv','Athul','Atul','Debashish_DC', 'Dhaka','Deepaksir','Dixit','Fayis','Gourav','Himanshu','Imran','Ishant','Komal','Krishna','Kshitij','Medha', 'Mohitkumar','Monish', 'Neha', 'Om','Prakash','Pranav','Pratip','Pritam','Purva','Raavya','Rajat', 'Ravis', 'Riddhi','Rishi','Rishika','Rutuja','Sangpriya','Shadwal','Shashank','Sibashish','Srishti','Swapnavo','Sweta','Tenin','Utkarsh','Vaidehi','Vanya','Venket','Vidushi','Vijay','Vimarsh','Yusuf'}
persons = {'P1','P2','P3','P4','P5'};

% load('dataset_original_erricsson.mat')

person_feat = [];


%for k = 1:size(persons,2)
for k = 1:5

load(sprintf('%s_all.mat', persons{k}))
% geo_data = dataset_original(:,k);
geo_data = smooth(geo_data,5);

% geo_data = geo_data(1:8000000);
% geo_data = wdenoise(geo_data,5,'DenoisingMethod','BlockJS');
% geo_data = wdenoise(geo_data,9,'Wavelet','db1' );


fprintf('Events and Features are extracted from the person %d \n',k)

clear Evnt_Ind prdct_clst prob_clust

tm = (0:length(geo_data)-1)/Fs; 
% window = 0.2200; % 250ms is taken as the window size
% wndw_ovrlap = 0.40;
wndw_smpl = window*Fs;

num_seg=floor(1+(length(geo_data)-wndw_smpl)/(floor((1-wndw_ovrlap)*wndw_smpl)));
i = 1;
iter = 1;


while iter < length(geo_data)
    
    start = floor(wndw_smpl*(i-1)*(1-wndw_ovrlap) + 1);
    stop = floor(start + wndw_smpl -1); 
    if stop >= length(geo_data)
        stop = length(geo_data);
    end
    gaussian_wndw = length(geo_data(start:stop));
   weight = gausswin(gaussian_wndw,tau);  % calculating gaussians weights 
    w_diag = diag(weight);
    sig = w_diag*geo_data(start:stop);
    
    Evnt_Ind(i,:) = [start , stop];
    
   
    
    test_data = Events_Features_Extraction(Fs,sig);
%     test_data  = featureNormalizeTest(test_data,mn_feat,sd_feat);

   prob_clust(i,1) = mvnpdf(test_data(:,1:end),mu_mat(1,:),cov_mat(:,:,1))*phi(1);
   prob_clust(i,2) = mvnpdf(test_data(:,1:end),mu_mat(2,:),cov_mat(:,:,2))*phi(2);
 
      
      
   
 i = i+1;
 iter = stop;


end



prob_clust=prob_clust./repmat(sum(prob_clust,2),1,size(prob_clust,2));

[c clust_assign] = max(prob_clust,[],2);

id = find(c<0.90);
c_idx = find(clust_assign == 1);
prdct_clst(c_idx,:) = lbl_clst1;
c_idx = find(clust_assign == 2);
prdct_clst(c_idx,:) = lbl_clst2;

prdct_clst(id,:) = 0;


Evnt_Ind = [Evnt_Ind , prdct_clst];

Sigma = 4.0; % Bandwidth parameter of the gaussian window
[Evnts_loc, footstep_feat] = Event_Extract(Evnt_Ind, geo_data, Sigma,k);

person_feat{k} = footstep_feat;
%person_EvntLoc{k}=Evnts_loc;


% figure(3)
% t = Fs*200;
% % t=tm;
% subplot(211)
% plot(tm(1:t),geo_data(1:t))
% xlabel('Samples')
% ylabel('Amplitue (V)')
% grid on
% hold off
% subplot(212)
% plot(tm(1:t),Extrctd_Evnts(1:t))
% grid on
% xlabel('Samples')
% ylabel('Amplitue (V)')

end
