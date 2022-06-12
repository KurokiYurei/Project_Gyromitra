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
    private EventInstance m_eventPasesDeMerda;

    private void Awake()
    {
        m_eventPasesDeMerda = FMODUnity.RuntimeManager.CreateInstance("event:/Personatge/12 - Passes terra");
    }

    public void PassesDeMerda()
    {
        //playSound()
    }

    public void StepLeft()
    {
        print("left");
    }    

    public void StepRight()
    {
        print("right");
    }

    private void playSound(EventInstance l_event)
    {
        l_event.set3DAttributes(FMODUnity.RuntimeUtils.To3DAttributes(m_soundEmitter.transform));
        l_event.start();
    }

    private void stopSound(EventInstance l_event)
    {
        l_event.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
    }
}
