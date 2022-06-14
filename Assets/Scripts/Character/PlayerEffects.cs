using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerEffects : MonoBehaviour
{
    [SerializeField]
    private GameObject m_groundRunEffect;

    [SerializeField]
    private GameObject m_leftFootFirepoint;
    [SerializeField]
    private GameObject m_rightFootFirepoint;

    public void StepLeft()
    {
        Debug.Log("left");
        GameObject _smokeVFX = Instantiate(m_groundRunEffect, m_leftFootFirepoint.transform.position, m_leftFootFirepoint.transform.rotation) as GameObject;
        Destroy(_smokeVFX, 2);
    }

    public void StepRight()
    {
        Debug.Log("right");
        GameObject _smokeVFX = Instantiate(m_groundRunEffect, m_rightFootFirepoint.transform.position, m_rightFootFirepoint.transform.rotation) as GameObject;
        Destroy(_smokeVFX, 2);
    }
}
