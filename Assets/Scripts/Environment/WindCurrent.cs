using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WindCurrent : MonoBehaviour
{
    public float m_pushPower;
    public float m_pushDuration;
    public Transform m_windDirection;
   
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player") && (other.GetComponent<CharacterControllerScript>().GetVerticalSpeed() < 10f && other.GetComponent<CharacterControllerScript>().GetVerticalSpeed() > -10f))
        {
            other.GetComponent<CharacterControllerScript>().SetBounceParameters
                (transform.position - m_windDirection.transform.position, m_pushPower, m_pushDuration);
        }
    }
}