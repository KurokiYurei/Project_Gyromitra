using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerEffects : MonoBehaviour
{
    [SerializeField]
    private GameObject m_groundRunEffect;
    [SerializeField]
    private GameObject m_jumpEffect;

    [SerializeField]
    private GameObject m_leftFootFirepoint;
    [SerializeField]
    private GameObject m_rightFootFirepoint;
    [SerializeField]
    private GameObject m_centerFootFirepoint;

    public void StepLeft()
    {
        GameObject _smokeVFX = Instantiate(m_groundRunEffect, m_leftFootFirepoint.transform.position, m_leftFootFirepoint.transform.rotation) as GameObject;
        Destroy(_smokeVFX, 2);
    }

    public void StepRight()
    {
        GameObject _smokeVFX = Instantiate(m_groundRunEffect, m_rightFootFirepoint.transform.position, m_rightFootFirepoint.transform.rotation) as GameObject;
        Destroy(_smokeVFX, 2);
    }

    public void JumpImpulse()
    {
        GameObject _smokeVFX = Instantiate(m_jumpEffect, m_centerFootFirepoint.transform.position, m_centerFootFirepoint.transform.rotation) as GameObject;
        Destroy(_smokeVFX, 2);
    }

    public void LandingEvent()
    {
        JumpImpulse();
        StepLeft();
        StepRight();
    }
}
