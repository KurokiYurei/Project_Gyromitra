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

    public void StepLeft()
    {
        GameObject _smokeVFX = Instantiate(m_groundWalkEffect, m_leftFootFirepoint.transform.position, m_leftFootFirepoint.transform.rotation) as GameObject;
        Destroy(_smokeVFX, 2);
    }

    public void StepRight()
    {
        GameObject _smokeVFX = Instantiate(m_groundWalkEffect, m_rightFootFirepoint.transform.position, m_rightFootFirepoint.transform.rotation) as GameObject;
        Destroy(_smokeVFX, 2);
    }
}
