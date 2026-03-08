"""XGBoost model for predictions"""
import xgboost as xgb

class XGBoostPredictor:
    def __init__(self):
        self.model = xgb.XGBClassifier()
    
    def train(self, X, y):
        self.model.fit(X, y)
    
    def predict(self, X):
        return self.model.predict(X)