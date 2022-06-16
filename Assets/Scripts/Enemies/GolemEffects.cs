using FMOD.Studio;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GolemEffects : MonoBehaviour
{
    [SerializeField]
    private GameObject m_groundWalkEffect;

    [SerializeField]
    private GameObject m_leftFootFirepoint;
    [SerializeField]
    private GameObject m_rightFootFirepoint;

    [Header("FMOD")]
    [SerializeField]
    private Transform m_soundEmitter;

    [SerializeField]
    private EventInstance m_eventStep;

    [SerializeField]
    private EventInstance m_eventDie;

    [SerializeField]
    private EventInstance m_eventMusic;

    private void Awake()
    {
        m_eventStep = FMODUnity.RuntimeManager.CreateInstance("event:/Enemics/21 - Golem step");
        m_eventDie = FMODUnity.RuntimeManager.CreateInstance("event:/Enemics/20 -  Golem death");
        m_eventMusic = FMODUnity.RuntimeManager.CreateInstance("event:/Music/BattleMusic");
    }

    public void StepLeft()
    {
        GameObject _smokeVFX = Instantiate(m_groundWalkEffect, m_leftFootFirepoint.transform.position, m_leftFootFirepoint.transform.rotation) as GameObject;
        Destroy(_smokeVFX, 2);
        UtilsGyromitra.stopSound(m_eventStep);
        UtilsGyromitra.playSound(m_eventStep, m_soundEmitter);
    }

    public void StepRight()
    {
        GameObject _smokeVFX = Instantiate(m_groundWalkEffect, m_rightFootFirepoint.transform.position, m_rightFootFirepoint.transform.rotation) as GameObject;
        Destroy(_smokeVFX, 2);
        UtilsGyromitra.stopSound(m_eventStep);
        UtilsGyromitra.playSound(m_eventStep, m_soundEmitter);
    }

    public void GolemDies()
    {
        UtilsGyromitra.stopSound(m_eventStep);
        UtilsGyromitra.playSound(m_eventDie, m_soundEmitter);
    }

    public void GolemMusicStancePlay()
    {
        UtilsGyromitra.playSound(m_eventMusic, m_soundEmitter);
    }

    public void GolemMusicStanceStop()
    {
        UtilsGyromitra.stopSound(m_eventMusic);
    }

}
