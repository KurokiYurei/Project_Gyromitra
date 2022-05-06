using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InstaDeath : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        IDamagable m_component = other.transform.GetComponent<IDamagable>();
        if(m_component != null ) m_component.Damage(100f);

    }
}
