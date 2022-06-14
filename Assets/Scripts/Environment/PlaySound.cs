using FMOD.Studio;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaySound : MonoBehaviour
{
    [Header("FMOD")]
    [SerializeField]
    private string m_eventString;

    private EventInstance m_sound;

    [SerializeField]
    private Transform m_emitterPos;

    [SerializeField]
    [Range(0.1f, 0.5f)]
    private float m_timer;

    private float m_currentTime;

    private void Awake()
    {
        m_sound = FMODUnity.RuntimeManager.CreateInstance(m_eventString);
        m_currentTime = m_timer;
    }

    private void Update()
    {
        m_currentTime -= Time.deltaTime;
        if(!UtilsGyromitra.IsPlaying(m_sound) && m_currentTime <= 0f)
        {
            UtilsGyromitra.stopSound(m_sound);
            UtilsGyromitra.playSound(m_sound, m_emitterPos);
            m_currentTime = m_timer;
        }
    }

}
