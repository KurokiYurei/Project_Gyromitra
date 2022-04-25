using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy1HP : MonoBehaviour, IDamagable
{
    public float m_health { get; set; }

    [SerializeField]
    private float m_maxHealth;

    public void Damage(float l_damage)
    {
        m_health -= l_damage;

        if(m_health <= 0)
        {
            Destroy(this.gameObject);
        }
    }

    private void Start()
    {
        m_health = m_maxHealth;
    }


}
