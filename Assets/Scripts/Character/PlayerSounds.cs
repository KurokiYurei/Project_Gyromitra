using FMOD.Studio;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerSounds : MonoBehaviour
{
    [Header("FMOD")]
    [SerializeField]
    private Transform m_soundEmitter;

    [SerializeField]
    private EventInstance m_eventStep;

    private void Awake()
    {
        m_eventStep = FMODUnity.RuntimeManager.CreateInstance("event:/Personatge/12 - Passes terra");
    }

    public void StepLeft()
    {
        UtilsGyromitra.stopSound(m_eventStep);
        print("left");
        UtilsGyromitra.playSound(m_eventStep, m_soundEmitter);

    }    

    public void StepRight()
    {
        UtilsGyromitra.stopSound(m_eventStep);
        print("right");
        UtilsGyromitra.playSound(m_eventStep, m_soundEmitter);
    }
}
