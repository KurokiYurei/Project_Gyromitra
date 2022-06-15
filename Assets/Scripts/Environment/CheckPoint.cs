using FMOD.Studio;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CheckPoint : MonoBehaviour
{
    public Transform m_startPosition;

    [Header("FMOD")]
    [SerializeField]
    private Transform m_soundEmitter;

    [SerializeField]
    private EventInstance m_eventCheckpoint;

    private void Awake()
    {
        m_eventCheckpoint = FMODUnity.RuntimeManager.CreateInstance("event:/Entorn/22 - Checkpoint");
    }

    public void PlaySound()
    {
        UtilsGyromitra.stopSound(m_eventCheckpoint);
        UtilsGyromitra.playSound(m_eventCheckpoint, m_soundEmitter);
    }
}
