using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMODUnity;
using FMOD.Studio;

public class Mushroom : MonoBehaviour
{
    private float m_timeToDestroy = 5.0f;
    private float m_currentTime;

    [SerializeField]
    private Vector3 targetscale;

    [SerializeField]
    private Animator m_animator;

    [SerializeField]
    private GameObject m_smokeVFX;

    [Header("FMOD")]
    [SerializeField]
    private Transform m_soundEmitter;

    [SerializeField]
    private EventInstance m_eventVerticalHit;

    [SerializeField]
    private EventInstance m_eventHorizontalHit;

    private void Awake()
    {
        m_eventHorizontalHit = FMODUnity.RuntimeManager.CreateInstance("event:/Bolet/8 - Rebot horitzontal");
        m_eventVerticalHit = FMODUnity.RuntimeManager.CreateInstance("event:/Bolet/9 - Rebot vertical");
    }
    void Update()
    {
        if (m_currentTime >= m_timeToDestroy)
        {
            DestroyMushroom();
        }
        m_currentTime += Time.deltaTime;

        if (m_animator.GetCurrentAnimatorStateInfo(0).IsName("Appearing"))
        {
            transform.localScale = Vector3.Lerp(transform.localScale, targetscale, m_animator.GetCurrentAnimatorStateInfo(0).normalizedTime);
        }
    }

    public void DestroyMushroom()
    {
        SmokeVFX();
        gameObject.SetActive(false);
        CharacterControllerScript.GetMushroomPool().m_ActiveElementsList.RemoveAt(0);
        //CharacterControllerScript.GetMushroomPool().m_CurrentAmount -= 1;

        m_currentTime = 0.0f;
    }

    public void SetCurrentTime(float value)
    {
        m_currentTime = value;
    }

    public void PlayHorizontalBounceAnim()
    {
        m_animator.SetTrigger("HorizontalBounce");
        UtilsGyromitra.playSound(m_eventHorizontalHit, m_soundEmitter);
    }

    public void PlayVerticalBounceAnim()
    {
        m_animator.SetTrigger("VerticalBounce");
        UtilsGyromitra.playSound(m_eventVerticalHit, m_soundEmitter);
    }

    public void SmokeVFX()
    {
        GameObject _smokeVFX = Instantiate(m_smokeVFX, this.transform.position, this.transform.rotation) as GameObject;
        Destroy(_smokeVFX, 2);
    }
}
