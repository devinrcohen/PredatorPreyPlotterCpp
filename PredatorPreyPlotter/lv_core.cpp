//
//  lv_core.cpp
//  PredatorPreyPlotter
//
//  Created by Devin R Cohen on 11/23/25.
//

#include "lv_core.hpp"

LVResultVectors lv_solve(
     double alpha,
     double beta,
     double gamma,
     double delta,
     double x0,
     double y0,
     double dt,
     int steps
) {
    LVResultVectors res;
    res.t.reserve(steps);
    res.prey.reserve(steps);
    res.predator.reserve(steps);
    
    auto dxdt = [alpha, beta](double x, double y, double t) {
        return alpha * x - beta * x * y;
    };
    
    auto dydt = [gamma, delta](double x, double y, double t) {
        return delta * x * y - gamma * y;
    };
    
    double t = 0.0;
    double x = x0;
    double y = y0;
    
    for(int i = 0; i < steps; ++i) {
        res.t.push_back(t);
        res.prey.push_back(x);
        res.predator.push_back(y);
        
        double k1x = dxdt(x, y, t);
        double k1y = dydt(x, y, t);
        
        double k2x = dxdt(x+k1x*dt/2.0, y+k1y*dt/2.0, t+dt/2.0);
        double k2y = dydt(x+k1x*dt/2.0, y+k1y*dt/2.0, t+dt/2.0);
        
        double k3x = dxdt(x+k2x*dt/2.0, y+k2y*dt/2.0, t+dt/2.0);
        double k3y = dydt(x+k2x*dt/2.0, y+k2y*dt/2.0, t+dt/2.0);
        
        double k4x = dxdt(x+k3x*dt, y+k3y*dt, t+dt);
        double k4y = dydt(x+k3x*dt, y+k3y*dt, t+dt);
        
        t += dt;
        x += dt/6.0*(k1x + 2.0*k2x + 2.0*k3x + k4x);
        y += dt/6.0*(k1y + 2.0*k2y + 2.0*k3y + k4y);
    }
    
    return res;
}
