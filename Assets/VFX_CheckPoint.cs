using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VFX_CheckPoint : MonoBehaviour
{
    public ParticleSystem VFX_CircleSpin;
    public ParticleSystem VFX_CCW;
    public ParticleSystem VFX_InnerRadius;
    public ParticleSystem VFX_OutterRadius;


    private void OnTriggerEnter(Collider other)
    {
        var cs = VFX_CircleSpin.main;
        var ccw = VFX_CCW.main;
        var ir = VFX_InnerRadius.main;
        var or = VFX_OutterRadius.main;

        cs.startColor = new ParticleSystem.MinMaxGradient(Color.green, Color.blue + Color.green);
        ccw.startColor = new ParticleSystem.MinMaxGradient(Color.green, Color.blue + Color.white);
        ir.startColor = new ParticleSystem.MinMaxGradient(Color.green, Color.green + Color.white);
        or.startColor = new ParticleSystem.MinMaxGradient(Color.green, Color.green +Color.blue);
    }

}
