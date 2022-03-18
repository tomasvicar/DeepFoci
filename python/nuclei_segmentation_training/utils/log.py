import numpy as np
import matplotlib.pyplot as plt

class Log():
    def __init__(self,names=['loss']):
        
        self.names=names
        
        self.model_names=[]
            
        
        self.train_log=dict(zip(names, [[]]*len(names)))
        self.valid_log=dict(zip(names, [[]]*len(names)))
        
        self.train_log_tmp=dict(zip(names, [[]]*len(names)))
        self.valid_log_tmp=dict(zip(names, [[]]*len(names)))


        
        
    def append_train(self,list_to_save):
        for value,name in zip(list_to_save,self.names):
            self.train_log_tmp[name] = self.train_log_tmp[name] + [value]
        
        
    def append_valid(self,list_to_save):
        for value,name in zip(list_to_save,self.names):
            self.valid_log_tmp[name] = self.valid_log_tmp[name] + [value]
        
        
    def save_and_reset(self):
        
        for name in self.names:
            self.train_log[name]= self.train_log[name] + [np.mean(self.train_log_tmp[name])]
            self.valid_log[name]= self.valid_log[name] + [np.mean(self.valid_log_tmp[name])]
        
        
        
        self.train_log_tmp=dict(zip(self.names, [[]]*len(self.names)))
        self.valid_log_tmp=dict(zip(self.names, [[]]*len(self.names)))
        
        
        
    def plot(self,save_name=None):
        if save_name is not None:
            save_names=[save_name,None]
        else:
            save_names=[None]
        
        for save_name in save_names:
            for name in self.names:
                plt.plot( self.train_log[name], label = 'train')
                plt.plot(self.valid_log[name], label = 'valid')
                plt.title(name)
                if save_name:
                    plt.savefig(save_name + name + '.png')
                plt.show()
                plt.close()
                
            
            
            
    def save_log_model_name(self,model_name):
        ## store model names
        self.model_names.append(model_name)